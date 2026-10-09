const sensitiveKey = /^(authorization|api[_-]?key|token|access[_-]?token|refresh[_-]?token|secret|password|service[_-]?role[_-]?key)$/i;

function redactText(text: string): string {
  return text
    .replace(/(?:Bearer|Basic)\s+[A-Za-z0-9._~+/=-]+/gi, "[AUTH REDACTED]")
    .replace(
      /((?:["']?(?:authorization|api[_-]?key|token|access[_-]?token|refresh[_-]?token|secret|password|service[_-]?role[_-]?key)["']?)\s*[:=]\s*)(?:"[^"]*"|'[^']*'|[^,;\n|&}]+)/gi,
      "$1[REDACTED]",
    );
}

export function describeError(error: unknown): string {
  try {
    if (error instanceof Error) {
      return redactText(`${error.name}: ${error.message}`);
    }
    if (typeof error === "string") {
      return redactText(error || "Leerer Fehlertext");
    }
    if (error === null) return "null";
    if (error === undefined) return "undefined";

    const seen = new WeakSet<object>();
    const json = JSON.stringify(error, (key, value: unknown) => {
      if (sensitiveKey.test(key)) return "[REDACTED]";
      if (typeof value === "bigint") return value.toString();
      if (typeof value === "object" && value !== null) {
        if (seen.has(value)) return "[Circular]";
        seen.add(value);
      }
      if (typeof value === "function") {
        return `[Function ${value.name || "anonymous"}]`;
      }
      if (typeof value === "symbol") return value.toString();
      return value;
    });
    if (typeof json === "string" && json.length > 0) return redactText(json);
  } catch (_) {
    // Die aeusserste No-Throw-Grenze faengt auch revoked Proxies,
    // werfende toJSON-Methoden und fehlerhafte Reflection ab.
  }

  return "Nicht serialisierbarer Fehler";
}
