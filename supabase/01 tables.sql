-- supabase/01_tables.sql
-- Run this first — creates all tables

-- ── Profiles ──────────────────────────────────────────────────────────────────
create table public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  full_name    text,
  avatar_url   text,
  phone        text,
  city         text,
  bio          text,
  is_verified  boolean default false,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- ── Rooms ─────────────────────────────────────────────────────────────────────
create table public.rooms (
  id                uuid primary key default gen_random_uuid(),
  owner_id          uuid references public.profiles(id) on delete cascade,
  title             text not null,
  description       text,
  city              text not null,
  area              text,
  price_per_month   numeric not null,
  area_sqft         numeric,
  phone             text,
  room_type         text default 'single',
  gender_preference text default 'any',
  status            text default 'active',
  has_wifi          boolean default false,
  has_ac            boolean default false,
  has_food          boolean default false,
  has_laundry       boolean default false,
  has_security      boolean default false,
  is_available_now  boolean default true,
  students_only     boolean default false,
  no_brokerage      boolean default false,
  latitude          float8,
  longitude         float8,
  rating            float8 default 0,
  created_at        timestamptz default now()
);

-- ── Room Images ───────────────────────────────────────────────────────────────
create table public.room_images (
  id        uuid primary key default gen_random_uuid(),
  room_id   uuid references public.rooms(id) on delete cascade,
  url       text not null,
  created_at timestamptz default now()
);

-- ── Favorites ─────────────────────────────────────────────────────────────────
create table public.favorites (
  id        uuid primary key default gen_random_uuid(),
  user_id   uuid references auth.users(id) on delete cascade,
  room_id   uuid references public.rooms(id) on delete cascade,
  created_at timestamptz default now(),
  unique(user_id, room_id)
);