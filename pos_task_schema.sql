-- SQL Schema for Pocket Mates / Handskill App
-- Run this in your Supabase SQL Editor

-- 1. POS Items (Custom local items created in POS)
CREATE TABLE IF NOT EXISTS pos_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    price DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    category TEXT DEFAULT 'General',
    is_service BOOLEAN DEFAULT false,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. POS Customers
CREATE TABLE IF NOT EXISTS pos_customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    orders_count INTEGER DEFAULT 0,
    total_spend DOUBLE PRECISION DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. POS Transactions / Invoices
CREATE TABLE IF NOT EXISTS pos_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    invoice_id TEXT NOT NULL,
    customer_name TEXT,
    items JSONB NOT NULL,
    subtotal DOUBLE PRECISION NOT NULL,
    tax DOUBLE PRECISION NOT NULL,
    discount DOUBLE PRECISION NOT NULL,
    total DOUBLE PRECISION NOT NULL,
    payment_method TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. User Tasks (Productivity)
CREATE TABLE IF NOT EXISTS user_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    notes TEXT,
    priority INTEGER DEFAULT 1, -- 0: high, 1: medium, 2: low
    is_completed BOOLEAN DEFAULT false,
    created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_date TIMESTAMP WITH TIME ZONE
);

-- 5. User Challenges (Productivity)
CREATE TABLE IF NOT EXISTS user_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    total_days INTEGER NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_date TIMESTAMP WITH TIME ZONE,
    is_completed BOOLEAN DEFAULT false,
    daily_ticks JSONB DEFAULT '{}'::jsonb
);

-- 6. User Schedules (Productivity)
CREATE TABLE IF NOT EXISTS user_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    color TEXT,
    is_completed BOOLEAN DEFAULT false,
    source INTEGER DEFAULT 0 -- 0: manual, 1: aiGenerated
);

-- Apply Row Level Security (RLS)
ALTER TABLE pos_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos_customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_schedules ENABLE ROW LEVEL SECURITY;

-- Create Policies so users can only access their own data
CREATE POLICY "Users can view their own pos items" ON pos_items FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own pos items" ON pos_items FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own pos items" ON pos_items FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own pos items" ON pos_items FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own pos customers" ON pos_customers FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own pos customers" ON pos_customers FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own pos customers" ON pos_customers FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own pos customers" ON pos_customers FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own pos transactions" ON pos_transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own pos transactions" ON pos_transactions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own pos transactions" ON pos_transactions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own pos transactions" ON pos_transactions FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own tasks" ON user_tasks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own tasks" ON user_tasks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own tasks" ON user_tasks FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own tasks" ON user_tasks FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own challenges" ON user_challenges FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own challenges" ON user_challenges FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own challenges" ON user_challenges FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own challenges" ON user_challenges FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own schedules" ON user_schedules FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own schedules" ON user_schedules FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own schedules" ON user_schedules FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own schedules" ON user_schedules FOR DELETE USING (auth.uid() = user_id);
