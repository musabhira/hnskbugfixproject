-- Enable PostGIS extension for geolocation support
create extension if not exists postgis schema extensions;

-- Create user_locations table to store real-time location
create table if not exists public.user_locations (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null unique,
  location geography(point) not null,
  is_active boolean default true,
  updated_at timestamp with time zone default now()
);

-- Enable Row Level Security
alter table public.user_locations enable row level security;

-- Policies
create policy "Allow read access for all authenticated users"
on public.user_locations for select
to authenticated
using (true);

create policy "Allow insert for own location"
on public.user_locations for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Allow update for own location"
on public.user_locations for update
to authenticated
using (auth.uid() = user_id);

-- Function to find nearby users
-- Call via: supabase.rpc('get_nearby_users', { lat: ..., long: ..., radius_meters: ... })
create or replace function get_nearby_users(
  lat double precision,
  long double precision,
  radius_meters double precision
)
returns table (
  user_id uuid,
  dist_meters double precision,
  name text,
  shop_name text,
  slug text,
  profile_image_url text,
  bg_color_code text,
  button_color_code text,
  is_verified boolean
)
language plpgsql
security definer
as $$
begin
  return query
  select
    ul.user_id,
    st_distance(ul.location, st_point(long, lat)::geography) as dist_meters,
    p.name,
    p.shop_name,
    p.slug,
    p.profile_image_url,
    p.bg_color_code,
    p.button_color_code,
    p.verified as is_verified
  from
    public.user_locations ul
  join
    public.profile p on ul.user_id = p.user_id
  where
    ul.is_active = true
    and ul.user_id != auth.uid()
    and st_dwithin(ul.location, st_point(long, lat)::geography, radius_meters)
  order by
    dist_meters asc;
end;
$$;
