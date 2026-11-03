-- Migration: 20261103_add_group_languages_and_language_warnings.sql
-- Description: Creates group_languages table and ensures group_activities has index for gang_allowed_languages

CREATE TABLE IF NOT EXISTS public.group_languages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL,
    language_code VARCHAR(10) NOT NULL,
    language_name VARCHAR(50),
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_group_language UNIQUE (group_id, language_code)
);

CREATE INDEX IF NOT EXISTS idx_group_languages_group_id ON public.group_languages(group_id);

-- Ensure group_activities index on activity_type
CREATE INDEX IF NOT EXISTS idx_group_activities_type ON public.group_activities(group_id, activity_type);

