-- Migration to add is_service column to gallery table
ALTER TABLE gallery ADD COLUMN is_service BOOLEAN DEFAULT FALSE;
