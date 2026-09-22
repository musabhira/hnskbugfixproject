-- Migration: expand statuses.media_type from varchar(10) to varchar(50)
-- Reason: 'citadel_fortress' (16 chars) exceeded the old varchar(10) limit,
--         causing "value too long" errors when sharing Citadel to Vibes.
-- Date: 2026-09-21

ALTER TABLE statuses ALTER COLUMN media_type TYPE varchar(50);
