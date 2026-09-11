const fs = require('fs');
const NL = String.fromCharCode(10);

const keys = {
  matSendFailed: ['Nachricht konnte nicht gesendet werden', 'Message could not be sent'],
  matItsAMatch: ['Es ist ein Match!', "It's a Match!"],
  matSayHint: ['Sag etwas Nettes ...', 'Say something nice ...'],
  supTitle: ['Hilfe & Support', 'Help & Support'],
  supSentTitle: ['Nachricht gesendet!', 'Message sent!'],
  supSentBody: ['Wir haben deine Nachricht erhalten und melden uns so schnell wie moeglich bei dir.', 'We received your message and will get back to you as soon as possible.'],
  supHeadline: ['Wie koennen wir helfen?', 'How can we help?'],
  supReplyTime: ['Wir antworten innerhalb von 24 Stunden', 'We reply within 24 hours'],
  supCategory: ['Kategorie', 'Category'],
  supMessage: ['Deine Nachricht', 'Your message'],
  supHint: ['Beschreibe dein Anliegen...', 'Describe your issue...'],
  supSend: ['Absenden', 'Submit'],
  supDirectContact: ['Direkter Kontakt', 'Direct contact'],
  supCatGeneral: ['Allgemein', 'General'],
  supCatTechnical: ['Technisches Problem', 'Technical problem'],
  supCatReportUser: ['Nutzer melden', 'Report a user'],
  supCatProfilePhotos: ['Profil / Fotos', 'Profile / photos'],
  supCatMatchChat: ['Match / Chat Problem', 'Match / chat problem'],
  supCatDeleteAccount: ['Account loeschen', 'Delete account'],
  supCatSuggestion: ['Verbesserungsvorschlag', 'Suggestion'],
  supCatOther: ['Sonstiges', 'Other'],
  errorWithMsg: ['Fehler: {msg}', 'Error: {msg}'],
};

function addKeys(path, idx) {
  const j = JSON.parse(fs.readFileSync(path, 'utf8'));
  let added = 0;
  for (const k of Object.keys(keys)) {
    if (j[k] !== undefined) { console.log('  skip (exists): ' + k); continue; }
    j[k] = keys[k][idx];
    if (k === 'errorWithMsg') j['@' + k] = { placeholders: { msg: { type: 'String' } } };
    added++;
  }
  fs.writeFileSync(path, JSON.stringify(j, null, 2) + NL, 'utf8');
  console.log(path + ': +' + added + ' keys');
}

addKeys('lib/l10n/app_de.arb', 0);
addKeys('lib/l10n/app_en.arb', 1);

function patch(file, pairs) {
  let s = fs.readFileSync(file, 'utf8');
  let n = 0;
  for (const [from, to] of pairs) {
    if (!s.includes(from)) { console.log('  !! NOT FOUND in ' + file + ': ' + from.slice(0, 60)); continue; }
    s = s.split(from).join(to);
    n++;
  }
  fs.writeFileSync(file, s, 'utf8');
  console.log(file + ': ' + n + '/' + pairs.length + ' patches');
}

const IMP = "import '../../l10n/app_localizations.dart';" + NL;

// ---- match_screen ----
const mf = 'lib/screens/match/match_screen.dart';
let ms = fs.readFileSync(mf, 'utf8');
if (!ms.includes('app_localizations.dart')) {
  ms = ms.replace("import '../../utils/theme.dart';" + NL, "import '../../utils/theme.dart';" + NL + IMP);
  fs.writeFileSync(mf, ms, 'utf8');
  console.log('  import added: ' + mf);
}
patch(mf, [
  ["        const SnackBar(" + NL + "          content: Text('Nachricht konnte nicht gesendet werden')," ,
   "        SnackBar(" + NL + "          content: Text(AppLocalizations.of(context)!.matSendFailed),"],
  ["                              const Text(" + NL + "                                'Es ist ein Match!'," ,
   "                              Text(" + NL + "                                AppLocalizations.of(context)!.matItsAMatch,"],
  ["              decoration: const InputDecoration(" + NL + "                hintText: 'Sag etwas Nettes ...'," ,
   "              decoration: InputDecoration(" + NL + "                hintText: AppLocalizations.of(context)!.matSayHint,"],
]);

// ---- support_screen ----
const sf = 'lib/screens/settings/support_screen.dart';
let ss = fs.readFileSync(sf, 'utf8');
if (!ss.includes('app_localizations.dart')) {
  ss = ss.replace("import '../../utils/theme.dart';" + NL, "import '../../utils/theme.dart';" + NL + IMP);
}
// category label helper (canonical DE values stay in DB)
ss = ss.replace(
  "  Future<void> _sendReport() async {",
  "  String _catLabel(BuildContext context, String c) {" + NL +
  "    final l = AppLocalizations.of(context)!;" + NL +
  "    switch (c) {" + NL +
  "      case 'Allgemein': return l.supCatGeneral;" + NL +
  "      case 'Technisches Problem': return l.supCatTechnical;" + NL +
  "      case 'Nutzer melden': return l.supCatReportUser;" + NL +
  "      case 'Profil / Fotos': return l.supCatProfilePhotos;" + NL +
  "      case 'Match / Chat Problem': return l.supCatMatchChat;" + NL +
  "      case 'Account loeschen': return l.supCatDeleteAccount;" + NL +
  "      case 'Verbesserungsvorschlag': return l.supCatSuggestion;" + NL +
  "      case 'Sonstiges': return l.supCatOther;" + NL +
  "      default: return c;" + NL +
  "    }" + NL +
  "  }" + NL + NL +
  "  Future<void> _sendReport() async {"
);
fs.writeFileSync(sf, ss, 'utf8');
patch(sf, [
  ["Text('Fehler: $e')", "Text(AppLocalizations.of(context)!.errorWithMsg(e.toString()))"],
  ["appBar: AppBar(title: const Text('Hilfe & Support'))", "appBar: AppBar(title: Text(AppLocalizations.of(context)!.supTitle))"],
  ["const Text('Nachricht gesendet!', style: TextStyle(", "Text(AppLocalizations.of(context)!.supSentTitle, style: const TextStyle("],
  ["              'Wir haben deine Nachricht erhalten und melden uns so schnell wie moeglich bei dir.',", "              AppLocalizations.of(context)!.supSentBody,"],
  ["const Text('Zurueck', style: TextStyle(", "Text(AppLocalizations.of(context)!.back, style: const TextStyle("],
  ["const Text('Wie koennen wir helfen?', style: TextStyle(", "Text(AppLocalizations.of(context)!.supHeadline, style: const TextStyle("],
  ["Text('Wir antworten innerhalb von 24 Stunden', style:", "Text(AppLocalizations.of(context)!.supReplyTime, style:"],
  ["const Text('Kategorie', style: TextStyle(", "Text(AppLocalizations.of(context)!.supCategory, style: const TextStyle("],
  ["const Text('Deine Nachricht', style: TextStyle(", "Text(AppLocalizations.of(context)!.supMessage, style: const TextStyle("],
  ["hintText: 'Beschreibe dein Anliegen...',", "hintText: AppLocalizations.of(context)!.supHint,"],
  ["const Text('Absenden', style: TextStyle(", "Text(AppLocalizations.of(context)!.supSend, style: const TextStyle("],
  ["const Text('Direkter Kontakt', style: TextStyle(", "Text(AppLocalizations.of(context)!.supDirectContact, style: const TextStyle("],
  ["child: Text(c))).toList()", "child: Text(_catLabel(context, c)))).toList()"],
]);
console.log('DONE');
