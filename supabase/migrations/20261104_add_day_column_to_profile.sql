-- Ensure day column exists on profile, defaults to 1, and backfills null values
ALTER TABLE public.profile 
  ADD COLUMN IF NOT EXISTS day integer DEFAULT 1;

ALTER TABLE public.profile 
  ALTER COLUMN day SET DEFAULT 1;

UPDATE public.profile 
SET day = COALESCE(day, learning_day, level, 1) 
WHERE day IS NULL;

CREATE INDEX IF NOT EXISTS idx_profile_day ON public.profile(day);

