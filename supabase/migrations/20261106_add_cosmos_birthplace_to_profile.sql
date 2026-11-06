-- =============================================================================
-- 🌌 Supabase Migration: Add Cosmos Birthplace Deed & Exclusive Plot Columns
-- Guarantees 100% exclusivity: No two users can ever own the same plot or PIN!
-- =============================================================================

ALTER TABLE public.profile 
  ADD COLUMN IF NOT EXISTS cosmos_planet text DEFAULT 'Earth Prime 🌍',
  ADD COLUMN IF NOT EXISTS cosmos_island_id integer,
  ADD COLUMN IF NOT EXISTS cosmos_island_name text,
  ADD COLUMN IF NOT EXISTS cosmos_plot_number integer,
  ADD COLUMN IF NOT EXISTS cosmos_pin text,
  ADD COLUMN IF NOT EXISTS cosmos_street text,
  ADD COLUMN IF NOT EXISTS cosmos_allocated_at timestamptz;

-- Enforce absolute exclusivity: Unique PIN & Unique Plot on each Island
CREATE UNIQUE INDEX IF NOT EXISTS idx_profile_cosmos_pin 
  ON public.profile(cosmos_pin) 
  WHERE cosmos_pin IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_profile_exclusive_island_plot 
  ON public.profile(cosmos_planet, cosmos_island_id, cosmos_plot_number) 
  WHERE cosmos_plot_number IS NOT NULL AND cosmos_island_id IS NOT NULL;

-- =============================================================================
-- 👥 BACKFILL ALL EXISTING USERS DETERMINISTICALLY
-- Assigns each existing user a permanent, exclusive plot across Earth Prime's islands
-- (35 citizens per island). Seniority by created_at.
-- =============================================================================
WITH numbered_existing_users AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (ORDER BY created_at ASC NULLS LAST, id ASC) - 1 AS row_idx
  FROM public.profile
  WHERE cosmos_plot_number IS NULL OR cosmos_pin IS NULL
),
island_catalog AS (
  SELECT * FROM (VALUES
    (0, 301, 'Ocean Whisper Atoll', 'Reefway Avenue'),
    (1, 302, 'Haven Peninsula', 'Highland Crest Road'),
    (2, 303, 'Tranquil Bay Isle', 'Emerald Coastal Boulevard'),
    (3, 304, 'Sunset Sanctuary', 'Golden Beach Drive'),
    (4, 305, 'Azure Coral Isle', 'Palm Shore Walkway'),
    (5, 306, 'Crescent Cove', 'Marina View Way'),
    (6, 307, 'Emerald Key', 'Coconut Palm Terrace'),
    (7, 308, 'Starfish Haven', 'Seashell Passage'),
    (8, 309, 'Breeze Lagoon', 'Windward Trail'),
    (9, 310, 'Coral Citadel', 'Sunburst Walk')
  ) AS t(island_idx, island_id, island_name, street_name)
)
UPDATE public.profile p
SET 
  cosmos_planet = 'Earth Prime 🌍',
  cosmos_island_id = ic.island_id,
  cosmos_island_name = ic.island_name,
  cosmos_plot_number = (neu.row_idx % 35) + 1,
  cosmos_pin = 'PKT-EP' || ic.island_id || '-P' || ((neu.row_idx % 35) + 1),
  cosmos_street = ic.street_name,
  cosmos_allocated_at = COALESCE(p.cosmos_allocated_at, now())
FROM numbered_existing_users neu
JOIN island_catalog ic ON ic.island_idx = ((neu.row_idx / 35) % 10)
WHERE p.id = neu.id;

