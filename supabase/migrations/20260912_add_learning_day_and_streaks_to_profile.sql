-- Add missing columns to profile table for learning system, streak tracking, and search functionality
ALTER TABLE public.profile 
  ADD COLUMN IF NOT EXISTS learning_day integer DEFAULT 1,
  ADD COLUMN IF NOT EXISTS learning_stage integer DEFAULT 1,
  ADD COLUMN IF NOT EXISTS learning_points integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS learning_streak integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_learning_date text,
  ADD COLUMN IF NOT EXISTS daily_streak integer DEFAULT 0;
