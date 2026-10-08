\set ON_ERROR_STOP on

create extension if not exists pgcrypto;
create schema if not exists auth;

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    create role service_role nologin bypassrls;
  end if;
end $$;

grant usage on schema public, auth to anon, authenticated, service_role;

create table auth.users (
  id uuid primary key,
  email text unique
);

create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$;

grant execute on function auth.uid() to anon, authenticated, service_role;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  birth_date date not null,
  is_active boolean not null default true
);

create table public.likes (
  id uuid primary key default gen_random_uuid(),
  from_user uuid references public.profiles(id),
  to_user uuid references public.profiles(id)
);
create table public.matches (
  id uuid primary key default gen_random_uuid(),
  user1 uuid references public.profiles(id),
  user2 uuid references public.profiles(id)
);
create table public.messages (
  id uuid primary key default gen_random_uuid(),
  match_id uuid references public.matches(id),
  sender_id uuid references public.profiles(id),
  content text not null default ''
);
create table public.blocks (
  id uuid primary key default gen_random_uuid(),
  blocker_id uuid references public.profiles(id),
  blocked_id uuid references public.profiles(id)
);
create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references public.profiles(id),
  reported_id uuid references public.profiles(id)
);
create table public.support_tickets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id)
);
create table public.dislikes (
  id uuid primary key default gen_random_uuid(),
  from_user uuid references public.profiles(id),
  to_user uuid references public.profiles(id)
);

alter table public.profiles enable row level security;
create policy "Anyone can view active profiles" on public.profiles
  for select to authenticated using (is_active = true);
create policy "Users can update own profile" on public.profiles
  for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

do $$
declare
  v_table text;
begin
  foreach v_table in array array[
    'likes', 'matches', 'messages', 'blocks',
    'reports', 'support_tickets', 'dislikes'
  ] loop
    execute format('alter table public.%I enable row level security', v_table);
    execute format(
      'create policy "Fixture authenticated access" on public.%I for all to authenticated using (true) with check (true)',
      v_table
    );
  end loop;
end $$;

grant select, insert, update, delete on all tables in schema public
  to authenticated, service_role;
