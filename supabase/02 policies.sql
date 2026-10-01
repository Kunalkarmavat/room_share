-- supabase/02_policies.sql
-- Run after 01_tables.sql

-- ── Profiles ──────────────────────────────────────────────────────────────────
alter table public.profiles enable row level security;

create policy "Profiles are viewable by everyone"
  on public.profiles for select using (true);

create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- ── Rooms ─────────────────────────────────────────────────────────────────────
alter table public.rooms enable row level security;

create policy "Anyone can read active rooms"
  on public.rooms for select using (true);

create policy "Authenticated users can insert rooms"
  on public.rooms for insert
  with check (auth.uid() = owner_id);

create policy "Owners can update their rooms"
  on public.rooms for update
  using (auth.uid() = owner_id);

create policy "Owners can delete their rooms"
  on public.rooms for delete
  using (auth.uid() = owner_id);

-- ── Room Images ───────────────────────────────────────────────────────────────
alter table public.room_images enable row level security;

create policy "Anyone can view room images"
  on public.room_images for select using (true);

create policy "Room owners can manage images"
  on public.room_images for all
  using (
    exists (
      select 1 from public.rooms
      where rooms.id = room_images.room_id
        and rooms.owner_id = auth.uid()
    )
  );

-- ── Favorites ─────────────────────────────────────────────────────────────────
alter table public.favorites enable row level security;

create policy "Users can manage their own favorites"
  on public.favorites for all
  using (auth.uid() = user_id);