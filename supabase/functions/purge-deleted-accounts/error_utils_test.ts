import { describeError } from "./error_utils.ts";

function assertSafeText(text: string): void {
  if (!text || text.includes("[object Object]")) {
    throw new Error(`Ungueltiger Text: ${text}`);
  }
}

Deno.test("describeError serialisiert Supabase-artige Objekte", () => {
  const text = describeError({ message: "permission denied", code: "42501" });
  if (!text.includes("permission denied") || !text.includes("42501")) {
    throw new Error(`Unerwarteter Text: ${text}`);
  }
});

Deno.test("describeError ist kreisfest", () => {
  const cyclic: Record<string, unknown> = { message: "boom" };
  cyclic.self = cyclic;
  const text = describeError(cyclic);
  if (!text.includes("boom") || !text.includes("[Circular]")) {
    throw new Error(`Zirkulaerer Fehler nicht lesbar: ${text}`);
  }
});

Deno.test("describeError redigiert Secrets rekursiv", () => {
  const text = describeError({
    authorization: "Bearer TOPSECRET",
    nested: { apiKey: "PRIVATE", password: "PASS" },
  });
  for (const secret of ["TOPSECRET", "PRIVATE", "PASS"]) {
    if (text.includes(secret)) throw new Error(`Secret geleakt: ${text}`);
  }
  if (!text.includes("[REDACTED]")) throw new Error(`Redaction fehlt: ${text}`);
});

Deno.test("describeError redigiert Text-Credentials vollständig", () => {
  const values: unknown[] = [
    new Error("authorization=Basic TOPSECRET"),
    new Error("password: my secret"),
    "api_key='VERY PRIVATE VALUE'",
    "token=ABC123&next=ok",
    new Error('{"password":"TOP SECRET","api_key":"PRIVATE"}'),
    "{'authorization':'Basic ABCDEF'}",
  ];
  for (const value of values) {
    const text = describeError(value);
    for (const secret of ["TOPSECRET", "my secret", "VERY PRIVATE VALUE", "ABC123", "TOP SECRET", "PRIVATE", "ABCDEF"]) {
      if (text.includes(secret)) throw new Error(`Text-Secret geleakt: ${text}`);
    }
  }
});

Deno.test("describeError faengt werfendes toJSON", () => {
  const text = describeError({ toJSON: () => { throw new Error("boom"); } });
  assertSafeText(text);
});

Deno.test("describeError faengt revoked Proxy", () => {
  const revocable = Proxy.revocable({}, {});
  revocable.revoke();
  const text = describeError(revocable.proxy);
  assertSafeText(text);
});

Deno.test("describeError liefert fuer jeden unknown-Wert Text", () => {
  const values: unknown[] = [undefined, null, Symbol("x"), () => true, 5n];
  for (const value of values) assertSafeText(describeError(value));
});
