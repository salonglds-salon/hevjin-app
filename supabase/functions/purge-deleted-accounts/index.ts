// Hevjin: endgueltige Kontoloeschung nach 14 Tagen.
//
// Deployment (bewusst NICHT automatisch ausgefuehrt):
//   supabase functions deploy purge-deleted-accounts --no-verify-jwt
//
// Secrets:
//   SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY werden von Supabase bereitgestellt.
//   PURGE_CRON_SECRET muss als eigener CSPRNG-Wert gesetzt werden.

import { createClient } from "jsr:@supabase/supabase-js@2.117.2";

const supabaseUrl = Deno.env.get("SUPABASE_URL");
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const cronSecret = Deno.env.get("PURGE_CRON_SECRET");

if (!supabaseUrl || !serviceRoleKey || !cronSecret) {
  throw new Error("Pflicht-Secrets fuer purge-deleted-accounts fehlen");
}

const admin = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

type QueueItem = {
  user_id: string;
  match_ids: string[] | null;
  attempts: number;
  claim_id: string;
};

async function renewClaim(item: QueueItem): Promise<void> {
  if (!item.claim_id) throw new Error("Claim-ID fehlt");
  const leaseUntil = new Date(Date.now() + 60 * 60 * 1000).toISOString();
  const { data, error } = await admin
    .from("account_deletion_queue")
    .update({ lease_until: leaseUntil, updated_at: new Date().toISOString() })
    .eq("user_id", item.user_id)
    .eq("status", "processing")
    .eq("claim_id", item.claim_id)
    .select("user_id")
    .maybeSingle();
  if (error) throw error;
  if (!data) throw new Error("Claim verloren");
}

async function listFilesRecursive(
  bucket: string,
  prefix: string,
): Promise<string[]> {
  const files: string[] = [];
  let offset = 0;
  const limit = 100;

  while (true) {
    const { data, error } = await admin.storage.from(bucket).list(prefix, {
      limit,
      offset,
      sortBy: { column: "name", order: "asc" },
    });
    if (error) throw error;
    if (!data || data.length === 0) break;

    for (const entry of data) {
      const path = prefix ? `${prefix}/${entry.name}` : entry.name;
      if (entry.id == null) {
        files.push(...await listFilesRecursive(bucket, path));
      } else {
        files.push(path);
      }
    }

    if (data.length < limit) break;
    offset += limit;
  }

  return files;
}

async function removePrefix(bucket: string, prefix: string): Promise<void> {
  const files = await listFilesRecursive(bucket, prefix);
  for (let start = 0; start < files.length; start += 100) {
    const { error } = await admin.storage.from(bucket).remove(
      files.slice(start, start + 100),
    );
    if (error) throw error;
  }
}

async function listAllMatchIds(item: QueueItem): Promise<string[]> {
  const ids: string[] = [];
  const pageSize = 1000;
  let from = 0;

  while (true) {
    // Lease bei jeder Seite erneuern; max_rows=1000 darf den Snapshot niemals
    // still abschneiden, bevor der Auth-Cascade die DB-Zuordnung entfernt.
    await renewClaim(item);
    const { data, error } = await admin
      .from("matches")
      .select("id")
      .or(`user1.eq.${item.user_id},user2.eq.${item.user_id}`)
      .order("id", { ascending: true })
      .range(from, from + pageSize - 1);
    if (error) throw error;

    ids.push(...(data ?? []).map((match) => String(match.id)));
    if (!data || data.length < pageSize) break;
    from += pageSize;
  }

  return ids;
}

async function purgeOne(item: QueueItem): Promise<void> {
  const userId = item.user_id;
  let matchIds = item.match_ids ?? [];

  try {
    await renewClaim(item);
    // Die Claim-RPC hat diese Zeile atomar auf processing gesetzt. Cancel und
    // ein zweiter Worker koennen sie ab jetzt nicht mehr ueberholen.
    if (matchIds.length === 0) {
      matchIds = await listAllMatchIds(item);

      const { data: savedClaim, error: saveMatchIdsError } = await admin
        .from("account_deletion_queue")
        .update({ match_ids: matchIds, updated_at: new Date().toISOString() })
        .eq("user_id", userId)
        .eq("status", "processing")
        .eq("claim_id", item.claim_id)
        .select("user_id")
        .maybeSingle();
      if (saveMatchIdsError) throw saveMatchIdsError;
      if (!savedClaim) throw new Error("Claim verloren");
    }

    // Auth-User zuerst endgueltig loeschen. Die Migration erzwingt fuer alle
    // bekannten Nutzertabellen ON DELETE CASCADE. Bei FK-Problemen schlaegt
    // der Auth-Delete atomar fehl und Storage bleibt unberuehrt.
    const { data: userResult, error: userLookupError } =
      await admin.auth.admin.getUserById(userId);
    const lookupStatus = (userLookupError as { status?: number } | null)?.status;
    const lookupNotFound = lookupStatus === 404 ||
      userLookupError?.message.toLowerCase().includes("not found");
    if (userLookupError && !lookupNotFound) throw userLookupError;

    // Unmittelbar vor dem irreversiblen Schritt Claim erneuern/pruefen.
    await renewClaim(item);

    if (userResult.user) {
      const { error: deleteError } = await admin.auth.admin.deleteUser(
        userId,
        false,
      );
      if (deleteError) throw deleteError;
    }

    // Storage immer ueber die Storage API loeschen. SQL-DELETE auf
    // storage.objects wuerde physische Dateien verwaisen lassen.
    await removePrefix("profile-photos", userId);
    for (const matchId of matchIds) {
      await removePrefix("chat-images", `chat/${matchId}`);
    }

    // Keine unbegrenzte Retention von User-/Match-IDs: nach vollstaendigem
    // Cleanup wird der Queue-Eintrag selbst geloescht.
    const { data: deletedQueue, error: queueDeleteError } = await admin
      .from("account_deletion_queue")
      .delete()
      .eq("user_id", userId)
      .eq("status", "processing")
      .eq("claim_id", item.claim_id)
      .select("user_id")
      .maybeSingle();
    if (queueDeleteError) throw queueDeleteError;
    if (!deletedQueue) throw new Error("Claim verloren");
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    const requiresManualReview = item.attempts >= 5;
    const delayHours = Math.min(24, 2 ** Math.min(item.attempts, 4));
    const nextAttempt = requiresManualReview
      ? null
      : new Date(Date.now() + delayHours * 60 * 60 * 1000).toISOString();
    const reviewTime = requiresManualReview ? new Date() : null;

    // Nach 5 Fehlversuchen nicht endlos weiterclaimen. manual_review ist ein
    // terminaler operativer Alarmzustand; README definiert Prüfung/Retention.
    await admin
      .from("account_deletion_queue")
      .update({
        status: requiresManualReview ? "manual_review" : "failed",
        match_ids: matchIds,
        next_attempt_at: nextAttempt,
        claim_id: null,
        lease_until: null,
        manual_review_at: reviewTime?.toISOString() ?? null,
        review_deadline: reviewTime
          ? new Date(reviewTime.getTime() + 30 * 24 * 60 * 60 * 1000)
            .toISOString()
          : null,
        last_error: message.slice(0, 1000),
        updated_at: new Date().toISOString(),
      })
      .eq("user_id", userId)
      .eq("claim_id", item.claim_id);
    throw error;
  }
}

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }
  if (request.headers.get("x-cron-secret") !== cronSecret) {
    return new Response("Unauthorized", { status: 401 });
  }

  // Atomarer Claim mit FOR UPDATE SKIP LOCKED in Postgres. Nur tatsaechlich
  // geclaimte Zeilen kommen zurueck; parallele Worker erhalten andere Zeilen.
  const { data, error } = await admin.rpc("claim_account_deletions", {
    p_limit: 50,
  });

  if (error) {
    return Response.json({ ok: false, error: error.message }, { status: 500 });
  }

  const results: Array<{ userId: string; ok: boolean; error?: string }> = [];
  for (const item of (data ?? []) as QueueItem[]) {
    try {
      await purgeOne(item);
      results.push({ userId: item.user_id, ok: true });
    } catch (purgeError) {
      results.push({
        userId: item.user_id,
        ok: false,
        error: purgeError instanceof Error
          ? purgeError.message
          : String(purgeError),
      });
    }
  }

  const { count: manualReviewCount } = await admin
    .from("account_deletion_queue")
    .select("user_id", { count: "exact", head: true })
    .eq("status", "manual_review");
  const { count: overdueReviewCount } = await admin
    .from("account_deletion_queue")
    .select("user_id", { count: "exact", head: true })
    .eq("status", "manual_review")
    .lte("review_deadline", new Date().toISOString());

  if ((manualReviewCount ?? 0) > 0) {
    console.error(
      `ACCOUNT_DELETION_MANUAL_REVIEW count=${manualReviewCount} overdue=${overdueReviewCount ?? 0}`,
    );
  }

  return Response.json({
    ok: results.every((result) => result.ok),
    results,
    manualReviewCount: manualReviewCount ?? 0,
    overdueReviewCount: overdueReviewCount ?? 0,
  });
});
