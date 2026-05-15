import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";
dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function test() {
  console.log("Testing connection to:", process.env.SUPABASE_URL);
  const { data, error } = await supabase.from("pod_products").select("*");

  if (error) {
    console.error("❌ Connection failed!");
    console.error("Error code:", error.code);
    console.error("Error message:", error.message);
    if (error.code === "PGRST116") {
      console.log("💡 Tip: The table 'pod_products' might not exist yet. Please run the SQL migration.");
    }
    process.exit(1);
  }

  console.log("✅ Connection successful!");
  console.log(`Found ${data.length} products in 'pod_products'.`);
}

test();
