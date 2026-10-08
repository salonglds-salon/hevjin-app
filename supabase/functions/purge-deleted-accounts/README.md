# purge-deleted-accounts

Diese Function löscht Hevjîn-Konten **endgültig nach 14 Tagen**:

1. Auth-User löschen (`admin.deleteUser`, kein Soft-Delete)
2. DB-Cascades löschen Profil, Likes, Matches und Messages
3. Profilfotos unter `profile-photos/<user-id>/` löschen
4. Chat-Bilder unter `chat-images/chat/<match-id>/` löschen
5. Ergebnis in `account_deletion_queue` protokollieren

## Vor dem Deployment prüfen

```sql
-- Migration zuerst im Supabase SQL Editor ausführen:
-- supabase/migrations/20260915170000_account_deletion_queue.sql

-- Alle FKs, die das Löschen des Profils/Auth-Users blockieren könnten:
select
  tc.table_name,
  kcu.column_name,
  ccu.table_name as referenced_table,
  rc.delete_rule
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu
  on tc.constraint_name = kcu.constraint_name
 and tc.constraint_schema = kcu.constraint_schema
join information_schema.constraint_column_usage ccu
  on ccu.constraint_name = tc.constraint_name
 and ccu.constraint_schema = tc.constraint_schema
join information_schema.referential_constraints rc
  on rc.constraint_name = tc.constraint_name
 and rc.constraint_schema = tc.constraint_schema
where tc.constraint_type = 'FOREIGN KEY'
  and (tc.table_name in ('profiles','likes','matches','messages','blocks','reports','support_tickets','dislikes')
       or ccu.table_name in ('profiles','users'))
order by tc.table_name;
```

Alle nutzerbezogenen Constraints müssen `CASCADE` haben oder vor dem Auth-Delete explizit bereinigt werden. Wenn ein Constraint blockiert, markiert die Function den Queue-Eintrag als `failed` und löscht nichts aus Storage.

## Deployment

Nicht vom Amazon-Arbeitslaptop ausführen, wenn Supabase-/Deno-Zugriffe durch das VPN blockiert sind. Auf dem privaten Lenovo:

```powershell
supabase login
supabase link --project-ref lrmoxfjuhqesjoxjkftw
supabase functions deploy purge-deleted-accounts --no-verify-jwt

# Eigenes kryptografisch zufälliges Secret setzen, nicht im Repo speichern:
$bytes = New-Object byte[] 48
[System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
$secret = [Convert]::ToBase64String($bytes)
supabase secrets set "PURGE_CRON_SECRET=$secret"
```

Danach im Supabase Dashboard einen täglichen Cron-Aufruf der Function konfigurieren und den Header `x-cron-secret` setzen. Den Secret-Wert nie in SQL-Dateien, Logs oder Chat kopieren.

## Sicherer Test

Nur mit einem neu angelegten Wegwerf-Testkonto testen, nie mit einem echten Nutzer:

1. Migration einspielen.
2. Mit Testkonto `request_account_deletion()` auslösen.
3. In `account_deletion_queue` ausschließlich beim Testkonto `purge_after = now()` setzen.
4. Function manuell mit Cron-Secret aufrufen.
5. Prüfen: Auth-User weg, Profil/Matches/Messages weg, Storage-Pfade weg, Queue-Status `completed`.
6. Erst nach erfolgreichem Test täglichen Cron aktivieren.

Das Ändern von `purge_after`, der Function-Aufruf und die Aktivierung des Cron sind produktive/destruktive Schritte und benötigen vorher ausdrückliche Bestätigung.

## Fehler, Manual Review und Retention

Fehler werden mit exponentiellem Backoff erneut versucht. Nach dem 5. Versuch wechselt der Eintrag in `manual_review` und wird nicht mehr automatisch geclaimt; die Function schreibt dann `ACCOUNT_DELETION_MANUAL_REVIEW` in die Function-Logs und liefert die Anzahl im JSON-Ergebnis.

Mindestens täglich prüfen:

```sql
select user_id, attempts, last_error, manual_review_at, review_deadline
from public.account_deletion_queue
where status = 'manual_review'
order by manual_review_at;
```

Ein Manual-Review-Fall muss vor `review_deadline` (30 Tage) geklärt werden. Nach Behebung der Ursache setzt ausschließlich ein Administrator den Eintrag über `retry_manual_account_deletion(user_id)` zurück; nach erfolgreichem Cleanup löscht die Function die Queue-Zeile vollständig. Die IDs werden nicht für Analyse oder Historie verwendet, sondern nur solange aufbewahrt, wie sie für die noch nicht abgeschlossene Löschung technisch erforderlich sind.
