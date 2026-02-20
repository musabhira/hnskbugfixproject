-- Migration to add web_template_id to public.profile
ALTER TABLE public.profile 
ADD COLUMN IF NOT EXISTS web_template_id TEXT DEFAULT 'default';

-- Update existing profiles to default template
UPDATE public.profile 
SET web_template_id = 'default' 
WHERE web_template_id IS NULL;
