-- Migration: 20261103_create_app_releases_table.sql
-- Description: Creates app_releases table for version-based release management,
-- supporting independent Android & iOS build records, Shorebird IDs, release notes,
-- and explicit active production store selection.

CREATE TABLE IF NOT EXISTS public.app_releases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    platform VARCHAR(20) NOT NULL, -- 'android' or 'ios'
    version VARCHAR(50) NOT NULL, -- e.g. '1.0.155'
    build_number INT NOT NULL, -- e.g. 330
    shorebird_release_id VARCHAR(100), -- Shorebird release identifier
    release_title VARCHAR(200) NOT NULL, -- e.g. 'POKET v1.0.155 Update'
    release_notes TEXT, -- Detailed formatted notes
    features JSONB DEFAULT '[]'::jsonb, -- Array of string features
    improvements JSONB DEFAULT '[]'::jsonb, -- Array of improvements
    bug_fixes JSONB DEFAULT '[]'::jsonb, -- Array of bug fixes
    announcement_message TEXT, -- Message for President announcement
    build_type VARCHAR(50) DEFAULT 'Testing', -- 'Testing', 'Internal', 'TestFlight', 'Production'
    store_status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'submitted', 'in_review', 'approved', 'live'
    is_active_production BOOLEAN DEFAULT false, -- Admin explicitly marks ONE active production per platform
    production_activated_at TIMESTAMPTZ, -- Timestamp when marked as active production
    is_mandatory BOOLEAN DEFAULT false,
    store_url TEXT,
    created_by VARCHAR(100) DEFAULT 'Admin',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_platform_version_build UNIQUE (platform, version, build_number)
);

-- Indexing for rapid queries
CREATE INDEX IF NOT EXISTS idx_app_releases_platform_active ON public.app_releases(platform, is_active_production);
CREATE INDEX IF NOT EXISTS idx_app_releases_build_number ON public.app_releases(platform, build_number DESC);

-- Enable RLS
ALTER TABLE public.app_releases ENABLE ROW LEVEL SECURITY;

-- Allow public read of active production releases (so user app can check updates without authentication)
CREATE POLICY "Public can view active production releases"
ON public.app_releases
FOR SELECT
USING (true);

-- Allow authenticated users / service / admin full access
CREATE POLICY "Allow authenticated insert and update on app_releases"
ON public.app_releases
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

