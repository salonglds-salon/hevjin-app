const fs = require('fs');
const NL = String.fromCharCode(10);

function patch(p, fn) {
  const lines = fs.readFileSync(p, 'utf8').split(/\r?\n/);
  const out = fn(lines);
  fs.writeFileSync(p, out.join(NL), 'utf8');
  console.log('patched ' + p);
}

// 1) language_provider.dart: EN deaktivieren
patch('lib/services/language_provider.dart', (l) => l.map((x) => {
  const t = x.trim();
  if (t === "Locale('en'),") return x.replace("Locale('en'),", "// Locale('en'),");
  if (t.startsWith("'en':")) return x.replace("'en':", "// 'en':");
  return x;
}));

// 2) Selector ausblenden, wenn nur eine Sprache aktiv ist
const guard = "    if (LanguageProvider.supportedLocales.length < 2) return const SizedBox.shrink();";

function addGuard(file, sig) {
  patch(file, (l) => {
    const i = l.findIndex((x) => x.includes(sig));
    if (i < 0) throw new Error('signature not found: ' + sig);
    if (l[i + 1] && l[i + 1].includes('supportedLocales.length')) return l;
    l.splice(i + 1, 0, guard);
    return l;
  });
}

addGuard('lib/screens/auth/welcome_screen.dart', 'Widget _buildLanguageSelector(');
addGuard('lib/screens/home/home_screen.dart', 'Widget _languageButton(');

console.log('DONE');
