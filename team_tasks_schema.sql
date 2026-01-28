-- Run this in your Supabase SQL Editor

-- 1. Create Teams Table
create table if not exists public.teams (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  name text not null,
  description text,
  created_by uuid references auth.users(id) not null
);

-- 2. Create Enums for Roles and Status
do $$ begin
    create type public.team_role as enum ('owner', 'admin', 'member');
exception
    when duplicate_object then null;
end $$;

do $$ begin
    create type public.member_status as enum ('pending', 'approved', 'rejected');
exception
    when duplicate_object then null;
end $$;

-- 3. Create Team Members Table
create table if not exists public.team_members (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  team_id uuid references public.teams(id) on delete cascade not null,
  user_id uuid references auth.users(id) not null,
  role public.team_role default 'member'::public.team_role not null,
  status public.member_status default 'pending'::public.member_status not null,
  unique(team_id, user_id)
);

-- 4. Create Team Tasks Table
create table if not exists public.team_tasks (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  team_id uuid references public.teams(id) on delete cascade not null,
  title text not null,
  description text,
  assigned_to uuid references auth.users(id),
  created_by uuid references auth.users(id) not null,
  due_date timestamp with time zone,
  status text default 'todo',
  priority text default 'medium'
);

-- 5. Enable Row Level Security (RLS)
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.team_tasks enable row level security;

-- 6. RLS Policies

-- Teams: View if you are a member (or pending)
create policy "View teams if member" on public.teams for select using (
  auth.uid() in (select user_id from public.team_members where team_id = id and status IN ('approved', 'pending'))
);

-- Teams: Create if you are authenticated
create policy "Create teams" on public.teams for insert with check (
  auth.uid() = created_by
);

-- Members: View members of your teams
create policy "View team members" on public.team_members for select using (
  team_id in (select team_id from public.team_members where user_id = auth.uid())
);

-- Members: Join requests (insert self)
create policy "Join request" on public.team_members for insert with check (
  auth.uid() = user_id
);

-- Tasks: View/Edit if approved member
create policy "View team tasks" on public.team_tasks for select using (
  team_id in (select team_id from public.team_members where user_id = auth.uid() and status = 'approved')
);

create policy "Create team tasks" on public.team_tasks for insert with check (
  team_id in (select team_id from public.team_members where user_id = auth.uid() and status = 'approved')
);

create policy "Update team tasks" on public.team_tasks for update using (
  team_id in (select team_id from public.team_members where user_id = auth.uid() and status = 'approved')
);
