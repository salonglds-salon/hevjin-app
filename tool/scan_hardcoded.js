// Scan Dart files for hardcoded German UI strings
const fs = require('fs');
const files = process.argv.slice(2);
const deChars = /[äöüßÄÖÜ]/;
const germanWords = /\b(der|die|das|und|oder|nicht|dein|deine|mein|meine|ein|eine|kein|keine|mit|von|zu|für|auf|ist|sind|wird|werden|hat|haben|wurde|bitte|Fehler|Speichern|Abbrechen|Löschen|Bearbeiten|Anzeigen|Senden|Weiter|Zurück|Foto|Fotos|Profil|Nachricht|Antwort|Frage|Konto|Einstellungen|Hilfe|Support|Danke|erfolgreich|erneut|versuchen|mindestens|maximal|ausgewählt|hinzufügen|entfernen|schon|noch|jetzt|dann|hier|alle|Alle)\b/;
for (const f of files) {
  const lines = fs.readFileSync(f, 'utf8').split(/\r?\n/);
  console.log('===== ' + f + ' (' + lines.length + ' lines)');
  lines.forEach((line, i) => {
    const t = line.trim();
    if (t.startsWith('//')) return;
    if (t.includes('AppLocalizations')) return;
    const re = /'([^'\\]{3,})'|"([^"\\]{3,})"/g;
    let m, hits = [];
    while ((m = re.exec(line)) !== null) {
      const s = m[1] || m[2];
      if (/^[a-z_]+$/.test(s)) continue;              // db keys
      if (/^[a-z_]+\.[a-z_]+$/.test(s)) continue;
      if (s.startsWith('assets/') || s.startsWith('http')) continue;
      if (!deChars.test(s) && !germanWords.test(s) && !/[A-ZÄÖÜ][a-zäöü]/.test(s)) continue;
      hits.push(s);
    }
    if (hits.length) console.log((i + 1) + ': ' + hits.join(' | '));
  });
}
