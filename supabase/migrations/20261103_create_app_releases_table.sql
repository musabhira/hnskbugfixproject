-- Migration: 20261103_create_app_releases_table.sql
-- Description: Creates app_releases table for version-based release management,
-- supporting independent Android & iOS build records, Shorebird IDs, GitHub Actions run metadata,
-- independent release notes, store submission tracking, and explicit active production store selection.

CREATE TABLE IF NOT EXISTS public.app_releases (
    id TEXT PRIMARY KEY, -- deterministic ID e.g. 'rel_ios_1.0.155_353' or UUID
    platform VARCHAR(20) NOT NULL, -- 'android' or 'ios'
    version VARCHAR(50) NOT NULL, -- e.g. '1.0.155'
    build_number INT NOT NULL, -- e.g. 353
    shorebird_release_id VARCHAR(100), -- Shorebird release identifier (e.g. '947685')
    git_commit_sha VARCHAR(64), -- Git commit SHA (e.g. '34db3a1...')
    github_workflow_name VARCHAR(100), -- e.g. 'Shorebird iOS Release & TestFlight'
    github_run_id VARCHAR(50), -- e.g. '41623654850'
    release_title VARCHAR(200) NOT NULL DEFAULT 'POKET Update', -- e.g. 'POKET v1.0.155 Update'
    release_notes TEXT DEFAULT '', -- Detailed formatted notes
    features JSONB DEFAULT '[]'::jsonb, -- Array of string features
    improvements JSONB DEFAULT '[]'::jsonb, -- Array of improvements
    bug_fixes JSONB DEFAULT '[]'::jsonb, -- Array of bug fixes
    announcement_message TEXT DEFAULT '', -- Message for President broadcast
    build_type VARCHAR(50) DEFAULT 'Testing', -- 'Testing', 'Internal', 'TestFlight', 'Production'
    shorebird_status VARCHAR(50) DEFAULT 'success', -- 'success', 'failed', 'pending'
    store_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'submitted', 'in_review', 'approved', 'live', 'failed'
    is_active_production BOOLEAN DEFAULT false, -- Admin explicitly marks ONE active production per platform
    production_activated_at TIMESTAMPTZ, -- Timestamp when marked as active production
    is_mandatory BOOLEAN DEFAULT false,
    store_url TEXT,
    created_by VARCHAR(100) DEFAULT 'GitHub Actions',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_platform_version_build UNIQUE (platform, version, build_number)
);

-- Indexing for rapid queries
CREATE INDEX IF NOT EXISTS idx_app_releases_platform_active ON public.app_releases(platform, is_active_production);
CREATE INDEX IF NOT EXISTS idx_app_releases_build_number ON public.app_releases(platform, build_number DESC);

-- Enable RLS
ALTER TABLE public.app_releases ENABLE ROW LEVEL SECURITY;

-- 1. Public read access: Anyone (including unauthenticated app launches) can read releases to check updates
CREATE POLICY "Public can view app releases"
ON public.app_releases
FOR SELECT
USING (true);

-- 2. Authenticated users / admin can insert & update
CREATE POLICY "Allow authenticated insert and update on app_releases"
ON public.app_releases
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- 3. Anonymous/Service role insert for GitHub Actions automated webhook/registration
CREATE POLICY "Allow anon insert or update on app_releases"
ON public.app_releases
FOR INSERT
TO anon
WITH CHECK (true);

CREATE POLICY "Allow anon update on app_releases"
ON public.app_releases
FOR UPDATE
TO anon
USING (true)
WITH CHECK (true);
