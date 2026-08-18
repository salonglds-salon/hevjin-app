// Gemeinsame Emoji-Zuordnung fuer alle Chip-Listen (Profil, Edit-Profil, Wizard).
// ASCII-Escapes verwenden - niemals rohe Emojis/Umlaute per PowerShell patchen.

const Map<String, String> kChipEmojis = {
  // ---- Interessen & Hobbys ----
  'Sport & Fitness': '\u{1F4AA}',
  'Zeit mit Familie': '\u{1F46A}',
  'Kochen & Essen': '\u{1F373}',
  'Reisen': '\u{2708}',
  'Lesen & Lernen': '\u{1F4DA}',
  'Gaming & Filme': '\u{1F3AE}',
  'Musik & Tanzen': '\u{1F3B5}',
  'Natur & Spazieren': '\u{1F33F}',
  'Caf\u00e9 & Freunde': '\u{2615}',
  'Fotografie': '\u{1F4F7}',
  'Autos & Technik': '\u{1F697}',
  'Kunst & Design': '\u{1F3A8}',

  // ---- Sport ----
  'Fitness': '\u{1F3CB}',
  'Fu\u00dfball': '\u{26BD}',
  'Schwimmen': '\u{1F3CA}',
  'Joggen': '\u{1F3C3}',
  'Yoga': '\u{1F9D8}',
  'Boxen': '\u{1F94A}',
  'Basketball': '\u{1F3C0}',
  'Tennis': '\u{1F3BE}',
  'Kampfsport': '\u{1F94B}',
  'Tanzen': '\u{1F483}',
  'Radfahren': '\u{1F6B4}',
  'Wandern': '\u{1F97E}',

  // ---- Reisen ----
  'Strandurlaub': '\u{1F3D6}',
  'St\u00e4dtereisen': '\u{1F3D9}',
  'Aktivurlaub': '\u{1F9D7}',
  'Camping & Natur': '\u{26FA}',
  'Wellness': '\u{1F486}',
  'Backpacking': '\u{1F392}',
  'Familienurlaub': '\u{1F46A}',
  'Kreuzfahrt': '\u{1F6F3}',

  // ---- Charakter & Eigenschaften ----
  'Humorvoll': '\u{1F604}',
  'Romantisch': '\u{1F339}',
  'Sportlich': '\u{1F3C5}',
  'Famili\u00e4r': '\u{1F3E1}',
  'Zuverl\u00e4ssig': '\u{1F91D}',
  'Ehrgeizig': '\u{1F3AF}',
  'Herzlich': '\u{1F49B}',
  'Weltoffen': '\u{1F30D}',
  'Traditionell': '\u{1F54A}',
  'Spontan': '\u{26A1}',
  'Kreativ': '\u{2728}',
  'Spirituell': '\u{1F56F}',
  'F\u00fcrsorglich': '\u{1F91A}',
  'Liebevoll': '\u{1F970}',
  'Gelassen': '\u{1F60C}',
  'Sch\u00fcchtern': '\u{1F648}',
  'Zielstrebig': '\u{1F680}',
  'Abenteuerlustig': '\u{1F9ED}',
  'Empathisch': '\u{1F932}',
  'Loyal': '\u{1F6E1}',
};

/// Normalisiert ein Label: Umlaute -> ae/oe/ue/ss, alles ausser a-z0-9 entfernt.
/// Damit matchen 'Fussball' == 'Fu\u00dfball' und 'Staedtereisen' == 'St\u00e4dtereisen'.
String normalizeChip(String s) => s
    .toLowerCase()
    .replaceAll('\u00e4', 'ae')
    .replaceAll('\u00f6', 'oe')
    .replaceAll('\u00fc', 'ue')
    .replaceAll('\u00df', 'ss')
    .replaceAll(RegExp(r'[^a-z0-9]'), '');

final Map<String, String> _normalizedEmojis = {
  for (final e in kChipEmojis.entries) normalizeChip(e.key): e.value,
};

/// Emoji fuer ein Chip-Label - umlaut-tolerant. Fallback: Funken-Emoji.
String chipEmoji(String label) =>
    _normalizedEmojis[normalizeChip(label)] ?? '\u{2728}';

/// Prueft umlaut-tolerant, ob [option] in [selected] enthalten ist.
/// Loest den Bug 'Fu\u00dfball' (DB) vs. 'Fussball' (Chip-Liste).
bool chipSelected(Iterable<String> selected, String option) {
  final target = normalizeChip(option);
  return selected.any((s) => normalizeChip(s) == target);
}
