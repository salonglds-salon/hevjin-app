\set ON_ERROR_STOP on
begin;

-- Katalog-/Berechtigungschecks.
do $$
begin
  if to_regclass('public.account_deletion_queue') is null then
    raise exception 'account_deletion_queue fehlt';
  end if;
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.profiles'::regclass
      and conname = 'profiles_adult_birth_date_check'
  ) then
    raise exception '18+-Constraint fehlt';
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles'
      and policyname = 'Hide deactivated profiles'
      and permissive = 'RESTRICTIVE'
  ) then
    raise exception 'Restriktive Deleted-Profile-Policy fehlt';
  end if;
  if not has_function_privilege(
    'authenticated', 'public.request_account_deletion()', 'EXECUTE'
  ) then
    raise exception 'authenticated darf request_account_deletion nicht ausfuehren';
  end if;
  if has_function_privilege(
    'authenticated', 'public.claim_account_deletions(integer)', 'EXECUTE'
  ) then
    raise exception 'authenticated darf Worker-Claim ausfuehren';
  end if;
  if not has_function_privilege(
    'service_role', 'public.claim_account_deletions(integer)', 'EXECUTE'
  ) then
    raise exception 'service_role darf Worker-Claim nicht ausfuehren';
  end if;
end $$;

-- Drei Erwachsene plus ein minderjaehriger Testdatensatz.
insert into auth.users (id, email) values
  ('10000000-0000-0000-0000-000000000001', 'adult1@test.local'),
  ('10000000-0000-0000-0000-000000000002', 'adult2@test.local'),
  ('10000000-0000-0000-0000-000000000003', 'adult3@test.local'),
  ('10000000-0000-0000-0000-000000000004', 'minor@test.local');

insert into public.profiles (id, birth_date) values
  ('10000000-0000-0000-0000-000000000001', date '1990-01-01'),
  ('10000000-0000-0000-0000-000000000002', date '1992-01-01'),
  ('10000000-0000-0000-0000-000000000003', date '1994-01-01');

insert into public.likes (from_user, to_user)
values ('10000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000002');

do $$
declare
  v_blocked boolean := false;
begin
  begin
    insert into public.profiles (id, birth_date)
    values (
      '10000000-0000-0000-0000-000000000004',
      (current_date - interval '17 years')::date
    );
  exception when check_violation then
    v_blocked := true;
  end;
  if not v_blocked then
    raise exception 'Serverseitiges 18+-Gate liess Minderjaehrigen durch';
  end if;
end $$;

-- Request und Cancel muessen atomar Profil + Queue aendern.
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);
set role authenticated;
do $$
begin
  if (select count(*) from public.likes) <> 1 then
    raise exception 'Aktiver Account wird durch RLS faelschlich blockiert';
  end if;
end $$;
select public.request_account_deletion();
reset role;

do $$
begin
  if not exists (
    select 1 from public.account_deletion_queue
    where user_id = '10000000-0000-0000-0000-000000000001'
      and status = 'pending'
  ) then
    raise exception 'Request legte keinen pending Queue-Eintrag an';
  end if;
  if not exists (
    select 1 from public.profiles
    where id = '10000000-0000-0000-0000-000000000001'
      and deleted_at is not null
  ) then
    raise exception 'Request deaktivierte Profil nicht';
  end if;
end $$;

-- Derselbe JWT darf nach Deaktivierung trotz permissiver Fixture-Policy keine
-- nutzerbezogenen Tabellen mehr lesen.
set role authenticated;
do $$
begin
  if (select count(*) from public.likes) <> 0 then
    raise exception 'Deaktivierter Account wird nicht durch RLS gesperrt';
  end if;
end $$;
select public.cancel_account_deletion();
reset role;

do $$
begin
  if exists (
    select 1 from public.account_deletion_queue
    where user_id = '10000000-0000-0000-0000-000000000001'
  ) then
    raise exception 'Cancel entfernte Queue-Eintrag nicht';
  end if;
  if not exists (
    select 1 from public.profiles
    where id = '10000000-0000-0000-0000-000000000001'
      and deleted_at is null
  ) then
    raise exception 'Cancel reaktivierte Profil nicht';
  end if;
end $$;

-- Claim darf einen Datensatz nur einmal vergeben; processing blockiert Cancel.
select public.request_account_deletion();
reset role;
update public.account_deletion_queue
set purge_after = now() - interval '1 minute'
where user_id = '10000000-0000-0000-0000-000000000001';

create temporary table first_claim as
select * from public.claim_account_deletions(1);
create temporary table second_claim as
select * from public.claim_account_deletions(1);

do $$
declare
  v_cancel_blocked boolean := false;
begin
  if (select count(*) from first_claim) <> 1 then
    raise exception 'Erster Claim lieferte nicht genau einen Eintrag';
  end if;
  if (select count(*) from second_claim) <> 0 then
    raise exception 'Derselbe processing-Eintrag wurde doppelt geclaimt';
  end if;
  if not exists (
    select 1 from public.account_deletion_queue
    where user_id = '10000000-0000-0000-0000-000000000001'
      and status = 'processing' and attempts = 1
      and claim_id is not null and lease_until > now()
  ) then
    raise exception 'Claim setzte Status/Attempts/Fencing nicht korrekt';
  end if;

  begin
    perform public.cancel_account_deletion();
  exception when others then
    v_cancel_blocked := true;
  end;
  if not v_cancel_blocked then
    raise exception 'Cancel durfte processing-Purge ueberholen';
  end if;
end $$;

-- Lease-Reclaim muss eine neue Claim-ID vergeben; ein alter Worker darf den
-- neuen Claim nicht per Compare-and-swap überschreiben.
update public.account_deletion_queue
set lease_until = now() - interval '1 minute'
where user_id = '10000000-0000-0000-0000-000000000001';

create temporary table reclaimed as
select * from public.claim_account_deletions(1);

create temporary table stale_write as
with changed as (
  update public.account_deletion_queue
  set status = 'failed'
  where user_id = '10000000-0000-0000-0000-000000000001'
    and claim_id = (select claim_id from first_claim)
  returning user_id
)
select * from changed;

do $$
begin
  if (select count(*) from reclaimed) <> 1 then
    raise exception 'Abgelaufener Lease wurde nicht erneut geclaimt';
  end if;
  if (select claim_id from reclaimed) = (select claim_id from first_claim) then
    raise exception 'Reclaim vergab keine neue Claim-ID';
  end if;
  if (select count(*) from stale_write) <> 0 then
    raise exception 'Alter Worker konnte neuen Claim überschreiben';
  end if;
end $$;

-- Bekannte Production-FKs muessen nach der Migration CASCADE sein.
do $$
begin
  if exists (
    select 1
    from pg_constraint
    where contype = 'f'
      and connamespace = 'public'::regnamespace
      and confdeltype <> 'c'
  ) then
    raise exception 'Mindestens ein Public-FK ist nicht ON DELETE CASCADE';
  end if;
end $$;

-- Cascade-End-to-End fuer einen separaten Nutzer.
insert into public.likes (from_user, to_user)
values ('10000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000002');
insert into public.blocks (blocker_id, blocked_id)
values ('10000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000002');
insert into public.reports (reporter_id, reported_id)
values ('10000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000002');
insert into public.support_tickets (user_id)
values ('10000000-0000-0000-0000-000000000003');
insert into public.dislikes (from_user, to_user)
values ('10000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000002');
insert into public.matches (id, user1, user2)
values ('20000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000002');
insert into public.messages (match_id, sender_id, content)
values ('20000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000003', 'test');

delete from auth.users
where id = '10000000-0000-0000-0000-000000000003';

do $$
begin
  if exists (select 1 from public.profiles where id = '10000000-0000-0000-0000-000000000003')
     or exists (select 1 from public.likes where from_user = '10000000-0000-0000-0000-000000000003')
     or exists (select 1 from public.matches where user1 = '10000000-0000-0000-0000-000000000003')
     or exists (select 1 from public.messages where sender_id = '10000000-0000-0000-0000-000000000003')
     or exists (select 1 from public.blocks where blocker_id = '10000000-0000-0000-0000-000000000003')
     or exists (select 1 from public.reports where reporter_id = '10000000-0000-0000-0000-000000000003')
     or exists (select 1 from public.support_tickets where user_id = '10000000-0000-0000-0000-000000000003')
     or exists (select 1 from public.dislikes where from_user = '10000000-0000-0000-0000-000000000003') then
    raise exception 'ON DELETE CASCADE ist unvollstaendig';
  end if;
end $$;

rollback;
