#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD="${PGPASSWORD:-postgres}"
PSQL=(psql -h 127.0.0.1 -U postgres -d postgres -v ON_ERROR_STOP=1)
USER_ID="30000000-0000-0000-0000-000000000001"

"${PSQL[@]}" -c "
  insert into public.account_deletion_queue
    (user_id, purge_after, status)
  values
    ('$USER_ID', now() - interval '1 minute', 'pending');
" >/dev/null

# Zwei echte PostgreSQL-Sessions versuchen gleichzeitig denselben Claim.
"${PSQL[@]}" -Atc "select user_id from public.claim_account_deletions(1);" > /tmp/hevjin-claim-1.txt &
PID1=$!
"${PSQL[@]}" -Atc "select user_id from public.claim_account_deletions(1);" > /tmp/hevjin-claim-2.txt &
PID2=$!
wait "$PID1"
wait "$PID2"

COUNT=$(cat /tmp/hevjin-claim-1.txt /tmp/hevjin-claim-2.txt | grep -c "^${USER_ID}$" || true)
if [[ "$COUNT" -ne 1 ]]; then
  echo "FEHLER: paralleler Claim wurde $COUNT-mal statt genau einmal vergeben"
  exit 1
fi

"${PSQL[@]}" -Atc "
  select case
    when status = 'processing' and attempts = 1 and claim_id is not null
      then 'ok'
    else 'invalid'
  end
  from public.account_deletion_queue
  where user_id = '$USER_ID';
" | grep -qx "ok"

"${PSQL[@]}" -c "delete from public.account_deletion_queue where user_id = '$USER_ID';" >/dev/null

echo "Concurrent claim test: OK"
