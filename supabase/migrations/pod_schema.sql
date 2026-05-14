-- ============================================================
-- Print-on-Demand Schema Migration
-- Run in: Supabase Dashboard > SQL Editor
-- ============================================================

-- 1. Product catalog (T-shirt, Mug, Bag templates)
create table if not exists public.pod_products (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  slug        text unique not null,
  glb_url     text default '',
  mockup_url  text default '',
  category    text default 'tshirt',
  base_cost   numeric(10,2) default 0,
  is_active   boolean default true,
  coming_soon boolean default false,
  sort_order  int default 0,
  created_at  timestamptz default now()
);

-- 2. Artist designs
create table if not exists public.pod_designs (
  id                uuid primary key default gen_random_uuid(),
  artist_id         uuid references auth.users(id) on delete cascade,
  product_id        uuid references public.pod_products(id),
  title             text not null,
  description       text default '',
  design_image_url  text not null,
  preview_image_url text default '',
  sale_price        numeric(10,2) not null default 499,
  royalty_pct       numeric(5,2) not null default 20,
  tags              text[] default '{}',
  status            text default 'draft'
    check (status in ('draft','published','paused')),
  created_at        timestamptz default now(),
  updated_at        timestamptz default now()
);

alter table public.pod_designs enable row level security;

create policy "Artist manages own designs"
  on public.pod_designs for all
  using (artist_id = auth.uid())
  with check (artist_id = auth.uid());

create policy "Anyone views published"
  on public.pod_designs for select
  using (status = 'published');

-- 3. Manual orders
create table if not exists public.pod_orders (
  id              uuid primary key default gen_random_uuid(),
  buyer_id        uuid references auth.users(id),
  design_id       uuid references public.pod_designs(id),
  quantity        int default 1,
  size            text default 'M',
  color           text default 'White',
  total_amount    numeric(10,2) not null,
  artist_payout   numeric(10,2) generated always as
                  (total_amount * (select royalty_pct/100 from pod_designs where id = design_id)) stored,
  buyer_name      text,
  buyer_phone     text,
  buyer_email     text,
  shipping_address jsonb default '{}',
  notes           text default '',
  tracking_number text default '',
  status          text default 'pending'
    check (status in ('pending','confirmed','printing','shipped','delivered','cancelled')),
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

alter table public.pod_orders enable row level security;
create policy "Buyer sees own orders" on public.pod_orders for select using (buyer_id = auth.uid());
create policy "Artist sees design orders"
  on public.pod_orders for select
  using (design_id in (select id from pod_designs where artist_id = auth.uid()));

-- 4. Seed product catalog
insert into public.pod_products (name, slug, category, base_cost, is_active, coming_soon, sort_order, glb_url)
values
  ('Classic T-Shirt', 'tshirt-classic', 'tshirt', 250, true,  false, 1, 'https://gswhynuabdspnwudltth.supabase.co/storage/v1/object/public/pod-glb-models/tshirt/model.gltf'),
  ('Coffee Mug',      'mug-classic',    'mug',    150, true,  true,  2, ''),
  ('Tote Bag',        'bag-tote',       'bag',    180, true,  true,  3, ''),
  ('Hoodie',          'hoodie-classic', 'hoodie', 450, true,  true,  4, '')
on conflict (slug) do nothing;

-- 5. Storage buckets (run separately if auto-creation fails)
-- insert into storage.buckets (id, name, public) values ('pod-design-uploads', 'pod-design-uploads', true) on conflict do nothing;
-- insert into storage.buckets (id, name, public) values ('pod-glb-models', 'pod-glb-models', true) on conflict do nothing;

-- Storage RLS
-- create policy "Auth upload designs" on storage.objects for insert with check (bucket_id = 'pod-design-uploads' and auth.role() = 'authenticated');
-- create policy "Public read designs" on storage.objects for select using (bucket_id = 'pod-design-uploads');
