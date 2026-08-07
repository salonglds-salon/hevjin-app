import 'dart:io';
void main() {
  final f = File('lib/screens/profile/create_profile_screen.dart');
  var c = f.readAsStringSync();
  final replacements = <String, String>{
    "const Text(''Grunddaten': Text(AppLocalizations.of(context)?.basicInfo ?? ''Grunddaten',
 ''Vorname *': (AppLocalizations.of(context)?.firstName ?? ''Vorname'') + '' *''',
 ''Weiter''': AppLocalizations.of(context)?.next ?? ''Weiter''',
 ''Profil erstellen''': AppLocalizations.of(context)?.createProfile ?? ''Profil erstellen''',
 };
 for (final entry in replacements.entries) {
 c = c.replaceAll(entry.key, entry.value);
 }
 f.writeAsStringSync(c);
 print('Done');
}
