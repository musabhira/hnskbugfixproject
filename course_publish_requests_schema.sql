-- Create course_publish_requests table for B2B e-learning platform
CREATE TABLE IF NOT EXISTS public.course_publish_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    creator_name TEXT NOT NULL,
    course_title TEXT NOT NULL,
    course_description TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.course_publish_requests ENABLE ROW LEVEL SECURITY;

-- Policies
-- 1. Users can insert their own requests
CREATE POLICY "Users can insert their own requests"
ON public.course_publish_requests
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- 2. Users can view their own requests
CREATE POLICY "Users can view their own requests"
ON public.course_publish_requests
FOR SELECT
USING (auth.uid() = user_id);

-- 3. Admins can view all requests (Assuming authenticated users for now if there is no specific admin role, or restrict as needed)
-- For this app, typically admins are authenticated users with specific emails or we can just let authenticated users select if they are in the admin panel.
CREATE POLICY "Admins can view all requests"
ON public.course_publish_requests
FOR SELECT
USING (auth.role() = 'authenticated');

-- 4. Admins can update all requests
CREATE POLICY "Admins can update requests"
ON public.course_publish_requests
FOR UPDATE
USING (auth.role() = 'authenticated');
