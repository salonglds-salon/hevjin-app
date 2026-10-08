-- Hevjin: race-sichere 14-Tage-Kontoloeschung
--
-- Die irreversible Loeschung erfolgt erst durch die Edge Function
-- purge-deleted-accounts nach Ablauf von purge_after.

alter table public.profiles
  add column if not exists deleted_at timestamptz;

create index if not exists profiles_deleted_at_idx
  on public.profiles (deleted_at)
  where deleted_at is not null;

-- 18+ auch serverseitig erzwingen. NOT VALID verhindert keinen neuen
-- Verstoss; VALIDATE bricht die Migration sicher ab, falls Altdaten ungueltig sind.
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.profiles'::regclass
      and conname = 'profiles_adult_birth_date_check'
  ) then
    alter table public.profiles
      add constraint profiles_adult_birth_date_check
      check (birth_date <= (current_date - interval '18 years')::date)
      not valid;
  end if;
end $$;

alter table public.profiles
  validate constraint profiles_adult_birth_date_check;

-- Restriktive Policy: selbst wenn weitere permissive SELECT-Policies bestehen,
-- sind deaktivierte Profile nur noch fuer den eigenen Reaktivierungsflow lesbar.
drop policy if exists "Hide deactivated profiles" on public.profiles;
create policy "Hide deactivated profiles"
  on public.profiles
  as restrictive
  for select
  to anon, authenticated
  using (deleted_at is null or id = auth.uid());

-- Nur die Security-Definer-RPCs duerfen deleted_at setzen/loeschen. Ein Client
-- kann die Queue dadurch nicht mit einem direkten Profile-UPDATE umgehen.
drop policy if exists "Only active profiles can be updated" on public.profiles;
create policy "Only active profiles can be updated"
  on public.profiles
  as restrictive
  for update
  to authenticated
  using (deleted_at is null)
  with check (deleted_at is null);

-- Ein deaktivierter Account darf auch mit einem noch gueltigen/stalen Token
-- keine Likes, Matches, Nachrichten oder sonstigen Nutzerdaten mehr lesen oder
-- schreiben. Restriktive Policies werden mit bestehenden Policies per AND
-- kombiniert, statt deren fachliche Regeln zu ersetzen.
do $$
declare
  v_table text;
begin
  foreach v_table in array array[
    'likes', 'matches', 'messages', 'blocks',
    'reports', 'support_tickets', 'dislikes'
  ] loop
    if to_regclass(format('public.%I', v_table)) is not null then
      execute format('alter table public.%I enable row level security', v_table);
      execute format(
        'drop policy if exists "Active accounts only" on public.%I',
        v_table
      );
      execute format(
        'create policy "Active accounts only" on public.%I as restrictive for all to authenticated using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.deleted_at is null)) with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.deleted_at is null))',
        v_table
      );
    end if;
  end loop;
end $$;

-- Kein Foreign Key auf auth.users: Nach admin.deleteUser() muss die Queue fuer
-- Storage-Cleanup und Retry erhalten bleiben. Nach Erfolg wird die Zeile geloescht.
create table if not exists public.account_deletion_queue (
  user_id uuid primary key,
  requested_at timestamptz not null default now(),
  purge_after timestamptz not null,
  status text not null default 'pending'
    check (status in ('pending', 'processing', 'failed', 'manual_review')),
  match_ids uuid[] not null default '{}',
  attempts integer not null default 0,
  claim_id uuid,
  lease_until timestamptz,
  next_attempt_at timestamptz,
  manual_review_at timestamptz,
  review_deadline timestamptz,
  last_error text,
  updated_at timestamptz not null default now()
);

create index if not exists account_deletion_queue_claim_idx
  on public.account_deletion_queue
    (status, next_attempt_at, purge_after, lease_until, updated_at);

alter table public.account_deletion_queue enable row level security;
revoke all on public.account_deletion_queue from public, anon, authenticated;
grant select, update, delete on public.account_deletion_queue to service_role;

-- Stellt sicher, dass ein erfolgreicher Auth-Delete die bekannten
-- nutzerbezogenen Tabellen reproduzierbar mitloescht. Die Migration bricht ab,
-- falls bestehende Daten einen Constraint verletzen; sie loescht keine Daten.
do $$
declare
  v_pair text[];
  v_table text;
  v_column text;
  v_constraint text;
  v_existing record;
begin
  -- profiles.id -> auth.users.id ist die Wurzel aller Cascades.
  for v_existing in
    select c.conname
    from pg_constraint c
    join pg_attribute a
      on a.attrelid = c.conrelid
     and a.attnum = c.conkey[1]
    where c.contype = 'f'
      and c.conrelid = 'public.profiles'::regclass
      and array_length(c.conkey, 1) = 1
      and a.attname = 'id'
  loop
    execute format(
      'alter table public.profiles drop constraint %I',
      v_existing.conname
    );
  end loop;

  alter table public.profiles
    add constraint profiles_id_auth_users_fk
    foreign key (id) references auth.users(id) on delete cascade;

  foreach v_pair slice 1 in array array[
    ['likes', 'from_user'], ['likes', 'to_user'],
    ['matches', 'user1'], ['matches', 'user2'],
    ['messages', 'sender_id'],
    ['blocks', 'blocker_id'], ['blocks', 'blocked_id'],
    ['reports', 'reporter_id'], ['reports', 'reported_id'],
    ['support_tickets', 'user_id'],
    ['dislikes', 'from_user'], ['dislikes', 'to_user']
  ] loop
    v_table := v_pair[1];
    v_column := v_pair[2];

    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = v_table
        and column_name = v_column
    ) then
      for v_existing in
        select c.conname
        from pg_constraint c
        join pg_attribute a
          on a.attrelid = c.conrelid
         and a.attnum = c.conkey[1]
        where c.contype = 'f'
          and c.conrelid = format('public.%I', v_table)::regclass
          and array_length(c.conkey, 1) = 1
          and a.attname = v_column
      loop
        execute format(
          'alter table public.%I drop constraint %I',
          v_table, v_existing.conname
        );
      end loop;

      v_constraint := format('%s_%s_profiles_fk', v_table, v_column);
      execute format(
        'alter table public.%I add constraint %I foreign key (%I) references public.profiles(id) on delete cascade',
        v_table, v_constraint, v_column
      );
    end if;
  end loop;

  -- messages.match_id muss vor dem Loeschen eines Matches kaskadieren.
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'messages'
      and column_name = 'match_id'
  ) then
    for v_existing in
      select c.conname
      from pg_constraint c
      join pg_attribute a
        on a.attrelid = c.conrelid
       and a.attnum = c.conkey[1]
      where c.contype = 'f'
        and c.conrelid = 'public.messages'::regclass
        and array_length(c.conkey, 1) = 1
        and a.attname = 'match_id'
    loop
      execute format(
        'alter table public.messages drop constraint %I',
        v_existing.conname
      );
    end loop;

    alter table public.messages
      add constraint messages_match_id_matches_fk
      foreign key (match_id) references public.matches(id) on delete cascade;
  end if;
end $$;

create or replace function public.request_account_deletion()
returns timestamptz
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_purge_after timestamptz := now() + interval '14 days';
  v_status text;
begin
  if v_user_id is null then
    raise exception 'Nicht angemeldet';
  end if;

  -- Synchronisiert Request mit Cancel/Claim fuer genau diesen Nutzer.
  select status into v_status
  from public.account_deletion_queue
  where user_id = v_user_id
  for update;

  if v_status = 'processing' then
    raise exception 'Loeschung wird bereits ausgefuehrt';
  end if;

  update public.profiles
     set deleted_at = now()
   where id = v_user_id;

  if not found then
    raise exception 'Profil nicht gefunden';
  end if;

  insert into public.account_deletion_queue (
    user_id, requested_at, purge_after, status, match_ids,
    attempts, claim_id, lease_until, next_attempt_at,
    manual_review_at, review_deadline, last_error, updated_at
  ) values (
    v_user_id, now(), v_purge_after, 'pending', '{}',
    0, null, null, null, null, null, null, now()
  )
  on conflict (user_id) do update set
    requested_at = excluded.requested_at,
    purge_after = excluded.purge_after,
    status = 'pending',
    match_ids = '{}',
    attempts = 0,
    claim_id = null,
    lease_until = null,
    next_attempt_at = null,
    manual_review_at = null,
    review_deadline = null,
    last_error = null,
    updated_at = now();

  return v_purge_after;
end;
$$;

create or replace function public.cancel_account_deletion()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_status text;
begin
  if v_user_id is null then
    raise exception 'Nicht angemeldet';
  end if;

  -- FOR UPDATE wartet auf einen parallelen Claim. Danach ist processing
  -- sichtbar und Reaktivierung kann den laufenden Purge nicht ueberholen.
  select status into v_status
  from public.account_deletion_queue
  where user_id = v_user_id
  for update;

  if v_status = 'processing' then
    raise exception 'Loeschung wird bereits ausgefuehrt';
  end if;

  update public.profiles
     set deleted_at = null
   where id = v_user_id;

  if not found then
    raise exception 'Profil nicht gefunden';
  end if;

  delete from public.account_deletion_queue
   where user_id = v_user_id;
end;
$$;

-- Atomarer Worker-Claim: parallele Cron-Aufrufe erhalten nie dieselbe Zeile.
-- Fehlversuche werden erst nach next_attempt_at erneut geclaimt.
create or replace function public.claim_account_deletions(p_limit integer default 50)
returns setof public.account_deletion_queue
language sql
security definer
set search_path = ''
as $$
  with candidates as (
    select q.user_id
    from public.account_deletion_queue q
    where q.purge_after <= now()
      and (
        q.status = 'pending'
        or (q.status = 'failed' and coalesce(q.next_attempt_at, now()) <= now())
        or (q.status = 'processing' and q.lease_until < now())
      )
    order by coalesce(q.next_attempt_at, q.purge_after), q.purge_after
    for update skip locked
    limit greatest(1, least(p_limit, 50))
  )
  update public.account_deletion_queue q
     set status = 'processing',
         attempts = q.attempts + 1,
         claim_id = gen_random_uuid(),
         lease_until = now() + interval '1 hour',
         next_attempt_at = null,
         last_error = null,
         updated_at = now()
    from candidates c
   where q.user_id = c.user_id
  returning q.*;
$$;

create or replace function public.retry_manual_account_deletion(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.account_deletion_queue
     set status = 'pending',
         attempts = 0,
         claim_id = null,
         lease_until = null,
         next_attempt_at = null,
         manual_review_at = null,
         review_deadline = null,
         last_error = null,
         updated_at = now()
   where user_id = p_user_id
     and status = 'manual_review';

  if not found then
    raise exception 'Kein Manual-Review-Eintrag gefunden';
  end if;
end;
$$;

revoke all on function public.request_account_deletion() from public, anon;
revoke all on function public.cancel_account_deletion() from public, anon;
revoke all on function public.claim_account_deletions(integer) from public, anon, authenticated;
revoke all on function public.retry_manual_account_deletion(uuid) from public, anon, authenticated;
grant execute on function public.request_account_deletion() to authenticated;
grant execute on function public.cancel_account_deletion() to authenticated;
grant execute on function public.claim_account_deletions(integer) to service_role;
grant execute on function public.retry_manual_account_deletion(uuid) to service_role;
