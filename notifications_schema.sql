-- 1. Update Team Tasks for Time Tracking and Extended Status
alter table public.team_tasks 
add column if not exists time_spent integer default 0, -- in minutes
add column if not exists parent_task_id uuid references public.team_tasks(id); -- for subtasks/threads

-- 2. Create Notifications Table
create table if not exists public.notifications (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  user_id uuid references auth.users(id) not null,
  type text not null, -- 'project_invite', 'task_assign', etc.
  source_id uuid not null, -- ID of the project/task
  message text not null,
  status text default 'unread' not null, -- 'unread', 'read', 'accepted', 'declined'
  sender_id uuid references auth.users(id) -- who sent the invite
);

-- 3. RLS for Notifications
alter table public.notifications enable row level security;

create policy "Users can view their own notifications" 
on public.notifications for select using (
  auth.uid() = user_id
);

create policy "Users can update their own notifications" 
on public.notifications for update using (
  auth.uid() = user_id
);

create policy "System/Users can insert notifications" 
on public.notifications for insert with check (
  true -- Usually controlled by backend logic, but allowing inserts for now
);
