import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { 
  ListToolsRequestSchema, 
  CallToolRequestSchema 
} from "@modelcontextprotocol/sdk/types.js";
import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL || "https://gswhynuabdspnwudltth.supabase.co";
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("Missing SUPABASE_URL or SUPABASE_KEY environment variables.");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

const server = new Server({
  name: "pocket-mates-custom-mcp",
  version: "2.0.0",
}, { capabilities: { tools: {} } });

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    // ── Existing tools ─────────────────────────────────────
    {
      name: "get_profile_by_id",
      description: "Get detailed profile information by user ID",
      inputSchema: { type: "object", properties: { userId: { type: "string" } }, required: ["userId"] },
    },
    {
      name: "list_user_services",
      description: "List all services provided by a specific user",
      inputSchema: { type: "object", properties: { userId: { type: "string" } }, required: ["userId"] },
    },
    {
      name: "get_database_summary",
      description: "Get a summary of the database tables and their status",
      inputSchema: { type: "object", properties: {} },
    },
    {
      name: "search_profiles",
      description: "Search profiles by name or bio",
      inputSchema: {
        type: "object",
        properties: {
          query: { type: "string" },
          limit: { type: "number", default: 10 }
        },
        required: ["query"]
      }
    },

    // ── POD: Product Catalog ─────────────────────────────────
    {
      name: "list_pod_products",
      description: "List all POD product templates (T-shirt, Mug, Bag etc.)",
      inputSchema: {
        type: "object",
        properties: {
          activeOnly: { type: "boolean", default: true }
        }
      }
    },
    {
      name: "get_pod_product_by_slug",
      description: "Get a single POD product template by its slug",
      inputSchema: {
        type: "object",
        properties: { slug: { type: "string" } },
        required: ["slug"]
      }
    },

    // ── POD: Design Management ───────────────────────────────
    {
      name: "create_pod_design",
      description: "Save a new artist design to the pod_designs table",
      inputSchema: {
        type: "object",
        properties: {
          artistId:       { type: "string" },
          productId:      { type: "string" },
          title:          { type: "string" },
          description:    { type: "string" },
          designImageUrl: { type: "string" },
          salePrice:      { type: "number" },
          royaltyPct:     { type: "number", default: 20 },
          tags:           { type: "array", items: { type: "string" } }
        },
        required: ["artistId", "productId", "title", "designImageUrl", "salePrice"]
      }
    },
    {
      name: "get_artist_pod_designs",
      description: "Get all POD designs for an artist, optionally filtered by status",
      inputSchema: {
        type: "object",
        properties: {
          artistId: { type: "string" },
          status:   { type: "string", enum: ["draft", "published", "paused", "all"] }
        },
        required: ["artistId"]
      }
    },
    {
      name: "update_pod_design_status",
      description: "Publish, pause, or revert a design to draft",
      inputSchema: {
        type: "object",
        properties: {
          designId: { type: "string" },
          status:   { type: "string", enum: ["draft", "published", "paused"] }
        },
        required: ["designId", "status"]
      }
    },
    {
      name: "update_pod_design_preview",
      description: "Update the preview_image_url of a design after screenshot capture",
      inputSchema: {
        type: "object",
        properties: {
          designId:        { type: "string" },
          previewImageUrl: { type: "string" }
        },
        required: ["designId", "previewImageUrl"]
      }
    },

    // ── POD: Marketplace ─────────────────────────────────────
    {
      name: "get_pod_marketplace_feed",
      description: "Get paginated list of published designs for the marketplace",
      inputSchema: {
        type: "object",
        properties: {
          limit:      { type: "number", default: 20 },
          offset:     { type: "number", default: 0 },
          category:   { type: "string" },
          artistId:   { type: "string" }
        }
      }
    },

    // ── POD: Orders ──────────────────────────────────────────
    {
      name: "create_pod_order",
      description: "Create a manual POD order",
      inputSchema: {
        type: "object",
        properties: {
          buyerId:         { type: "string" },
          designId:        { type: "string" },
          quantity:        { type: "number", default: 1 },
          size:            { type: "string" },
          color:           { type: "string" },
          totalAmount:     { type: "number" },
          buyerName:       { type: "string" },
          buyerPhone:      { type: "string" },
          buyerEmail:      { type: "string" },
          shippingAddress: { type: "object" },
          notes:           { type: "string" }
        },
        required: ["buyerId", "designId", "totalAmount", "buyerName", "buyerPhone"]
      }
    },
    {
      name: "get_pod_orders",
      description: "Get orders — for buyer or artist (via designId)",
      inputSchema: {
        type: "object",
        properties: {
          buyerId:  { type: "string" },
          artistId: { type: "string" },
          status:   { type: "string" }
        }
      }
    },
    {
      name: "update_pod_order_status",
      description: "Update order status and optional tracking number",
      inputSchema: {
        type: "object",
        properties: {
          orderId:        { type: "string" },
          status:         { type: "string" },
          trackingNumber: { type: "string" }
        },
        required: ["orderId", "status"]
      }
    },

    // ── POD: Analytics ───────────────────────────────────────
    {
      name: "get_pod_artist_stats",
      description: "Get order count and total earnings for an artist",
      inputSchema: {
        type: "object",
        properties: { artistId: { type: "string" } },
        required: ["artistId"]
      }
    }
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  try {
    switch (name) {

      // ── Existing handlers ─────────────────────────────────
      case "get_profile_by_id": {
        const { data, error } = await supabase.from('profiles').select('*').eq('id', args.userId).single();
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }
      case "list_user_services": {
        const { data, error } = await supabase.from('services').select('*').eq('user_id', args.userId);
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }
      case "get_database_summary": {
        const commonNames = ['profiles','services','hide','user_locations','teams','team_members',
          'team_tasks','notifications','pod_products','pod_designs','pod_orders'];
        const results = await Promise.all(commonNames.map(async (table) => {
          const { error } = await supabase.from(table).select('*', { count: 'exact', head: true }).limit(1);
          return { name: table, exists: !error || (error.code !== 'PGRST116' && error.code !== '42P01') };
        }));
        const existing = results.filter(r => r.exists).map(r => r.name);
        return { content: [{ type: "text", text: `Found ${existing.length} tables: ${existing.join(', ')}` }] };
      }
      case "search_profiles": {
        const { data, error } = await supabase.from('profiles').select('*')
          .or(`display_name.ilike.%${args.query}%,bio.ilike.%${args.query}%`).limit(args.limit || 10);
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }

      // ── POD: Product Catalog ─────────────────────────────
      case "list_pod_products": {
        let q = supabase.from('pod_products').select('*').order('sort_order');
        if (args.activeOnly !== false) q = q.eq('is_active', true);
        const { data, error } = await q;
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }
      case "get_pod_product_by_slug": {
        const { data, error } = await supabase.from('pod_products').select('*').eq('slug', args.slug).single();
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }

      // ── POD: Design Management ───────────────────────────
      case "create_pod_design": {
        const { data, error } = await supabase.from('pod_designs').insert({
          artist_id: args.artistId,
          product_id: args.productId,
          title: args.title,
          description: args.description || '',
          design_image_url: args.designImageUrl,
          sale_price: args.salePrice,
          royalty_pct: args.royaltyPct || 20,
          tags: args.tags || [],
          status: 'draft'
        }).select().single();
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }
      case "get_artist_pod_designs": {
        let q = supabase.from('pod_designs').select('*, pod_products(name, slug, category)')
          .eq('artist_id', args.artistId).order('created_at', { ascending: false });
        if (args.status && args.status !== 'all') q = q.eq('status', args.status);
        const { data, error } = await q;
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }
      case "update_pod_design_status": {
        const { data, error } = await supabase.from('pod_designs')
          .update({ status: args.status, updated_at: new Date().toISOString() })
          .eq('id', args.designId).select().single();
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }
      case "update_pod_design_preview": {
        const { data, error } = await supabase.from('pod_designs')
          .update({ preview_image_url: args.previewImageUrl, updated_at: new Date().toISOString() })
          .eq('id', args.designId).select().single();
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }

      // ── POD: Marketplace ─────────────────────────────────
      case "get_pod_marketplace_feed": {
        let q = supabase.from('pod_designs')
          .select('*, pod_products(name, slug, category), profiles(display_name, profile_image_url)')
          .eq('status', 'published')
          .order('created_at', { ascending: false })
          .range(args.offset || 0, (args.offset || 0) + (args.limit || 20) - 1);
        if (args.category) q = q.eq('pod_products.category', args.category);
        if (args.artistId) q = q.eq('artist_id', args.artistId);
        const { data, error } = await q;
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }

      // ── POD: Orders ──────────────────────────────────────
      case "create_pod_order": {
        const { data, error } = await supabase.from('pod_orders').insert({
          buyer_id: args.buyerId,
          design_id: args.designId,
          quantity: args.quantity || 1,
          size: args.size || 'M',
          color: args.color || 'White',
          total_amount: args.totalAmount,
          buyer_name: args.buyerName,
          buyer_phone: args.buyerPhone,
          buyer_email: args.buyerEmail || '',
          shipping_address: args.shippingAddress || {},
          notes: args.notes || '',
          status: 'pending'
        }).select().single();
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }
      case "get_pod_orders": {
        let q = supabase.from('pod_orders')
          .select('*, pod_designs(title, design_image_url, sale_price)')
          .order('created_at', { ascending: false });
        if (args.buyerId) q = q.eq('buyer_id', args.buyerId);
        if (args.status) q = q.eq('status', args.status);
        const { data, error } = await q;
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }
      case "update_pod_order_status": {
        const updateData = { status: args.status, updated_at: new Date().toISOString() };
        if (args.trackingNumber) updateData.tracking_number = args.trackingNumber;
        const { data, error } = await supabase.from('pod_orders')
          .update(updateData).eq('id', args.orderId).select().single();
        if (error) throw error;
        return { content: [{ type: "text", text: JSON.stringify(data) }] };
      }

      // ── POD: Analytics ───────────────────────────────────
      case "get_pod_artist_stats": {
        const { data: designs } = await supabase.from('pod_designs')
          .select('id, status').eq('artist_id', args.artistId);
        const designIds = designs?.map(d => d.id) || [];
        const { data: orders } = await supabase.from('pod_orders')
          .select('total_amount, status').in('design_id', designIds);
        const totalOrders = orders?.length || 0;
        const totalRevenue = orders?.reduce((sum, o) => sum + (o.total_amount || 0), 0) || 0;
        const publishedCount = designs?.filter(d => d.status === 'published').length || 0;
        return { content: [{ type: "text", text: JSON.stringify({ totalOrders, totalRevenue, publishedCount, totalDesigns: designs?.length || 0 }) }] };
      }

      default:
        throw new Error(`Tool not found: ${name}`);
    }
  } catch (error) {
    return { content: [{ type: "text", text: `Supabase Error: ${error.message}` }], isError: true };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
console.error("Pocket Mates Supabase MCP Server v2.0 running on stdio");
