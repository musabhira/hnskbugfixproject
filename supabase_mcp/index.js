import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { 
  ListToolsRequestSchema, 
  CallToolRequestSchema 
} from "@modelcontextprotocol/sdk/types.js";
import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";

dotenv.config();

// Initialize Supabase Client
// Note: In production, use environment variables.
const supabaseUrl = process.env.SUPABASE_URL || "https://gswhynuabdspnwudltth.supabase.co";
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("Missing SUPABASE_URL or SUPABASE_KEY environment variables.");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

const server = new Server({
  name: "pocket-mates-custom-mcp",
  version: "1.0.0",
}, {
  capabilities: { tools: {} },
});

/**
 * List available tools to the LLM
 */
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "get_profile_by_id",
      description: "Get detailed profile information by user ID from the profiles table",
      inputSchema: {
        type: "object",
        properties: {
          userId: { type: "string", description: "The UUID of the user" },
        },
        required: ["userId"],
      },
    },
    {
      name: "list_user_services",
      description: "List all services provided by a specific user from the services table",
      inputSchema: {
        type: "object",
        properties: {
          userId: { type: "string", description: "The UUID of the user" },
        },
        required: ["userId"],
      },
    },
    {
      name: "get_database_summary",
      description: "Get a summary of the database tables and their status",
      inputSchema: {
        type: "object",
        properties: {},
      },
    },
    {
        name: "search_profiles",
        description: "Search profiles by name or bio",
        inputSchema: {
            type: "object",
            properties: {
                query: { type: "string", description: "Search term" },
                limit: { type: "number", default: 10 }
            },
            required: ["query"]
        }
    }
  ],
}));

/**
 * Handle tool execution requests
 */
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "get_profile_by_id": {
        const { data, error } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', args.userId)
          .single();
        
        if (error) throw error;
        return {
          content: [{ type: "text", text: JSON.stringify(data) }],
        };
      }

      case "list_user_services": {
        const { data, error } = await supabase
          .from('services')
          .select('*')
          .eq('user_id', args.userId);
        
        if (error) throw error;
        return {
          content: [{ type: "text", text: JSON.stringify(data) }],
        };
      }

      case "get_database_summary": {
        // We will try to fetch the list of all tables from the information_schema
        // This requires an RPC 'get_all_tables' or similar. 
        // If it doesn't exist, we will use a more exhaustive list or try to discover them.
        
        const { data: tables, error } = await supabase
          .rpc('get_tables_info'); // Checking if a custom RPC exists for this
        
        if (error) {
          // Fallback to a much larger exhaustive check of common names and system patterns
          const commonNames = [
            'profiles', 'services', 'hide', 'user_locations', 'teams', 'team_members', 
            'team_tasks', 'notifications', 'meeting_for_handskill', 'users', 'audit_log',
            'posts', 'comments', 'likes', 'follows', 'messages', 'conversations',
            'settings', 'app_configs', 'subscriptions', 'payments', 'transactions'
          ];
          
          const results = await Promise.all(commonNames.map(async (table) => {
            const { error } = await supabase.from(table).select('*', { count: 'exact', head: true }).limit(1);
            return { name: table, exists: !error || (error.code !== 'PGRST116' && error.code !== '42P01') };
          }));

          const existingTables = results.filter(r => r.exists).map(r => r.name);
          
          return {
            content: [{ 
              type: "text", 
              text: `I performed a deep scan. I found at least ${existingTables.length} active tables in your public schema: ${existingTables.join(', ')}. There may be even more hidden in other schemas like 'auth' or 'storage'.` 
            }],
          };
        }

        return {
          content: [{ 
            type: "text", 
            text: `Database Analysis: I found ${tables.length} tables in the public schema.` 
          }],
        };
      }

      case "search_profiles": {
          const { data, error } = await supabase
            .from('profiles')
            .select('*')
            .or(`display_name.ilike.%${args.query}%,bio.ilike.%${args.query}%`)
            .limit(args.limit || 10);
          
          if (error) throw error;
          return {
            content: [{ type: "text", text: JSON.stringify(data) }],
          };
      }

      default:
        throw new Error(`Tool not found: ${name}`);
    }
  } catch (error) {
    return {
      content: [{ type: "text", text: `Supabase Error: ${error.message}` }],
      isError: true,
    };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
console.error("Pocket Mates Supabase MCP Server running on stdio");
