import 'dart:io';
void main() {
  final f = File('lib/screens/home/home_screen.dart');
  var c = f.readAsStringSync();
  // Revert broken replacements - put back original hardcoded strings
  c = c.replaceAll("AppLocalizations.of(context)?.caste ?? 'KASTE', 'KASTE');
 c = c.replaceAll(AppLocalizations.of(context)?.city ?? 'WOHNORT', 'WOHNORT');
 c = c.replaceAll(AppLocalizations.of(context)?.job ?? 'BERUF', 'BERUF');
 c = c.replaceAll(AppLocalizations.of(context)?.familyStatus ?? 'FAMILIENSTAND', 'FAMILIENSTAND');
 c = c.replaceAll(AppLocalizations.of(context)?.children ?? 'KINDER', 'KINDER');
 c = c.replaceAll(AppLocalizations.of(context)?.childWish ?? 'KINDERWUNSCH', 'KINDERWUNSCH');
 c = c.replaceAll(AppLocalizations.of(context)?.education ?? 'BILDUNGSABSCHLUSS', 'BILDUNGSABSCHLUSS');
 c = c.replaceAll(AppLocalizations.of(context)?.profile ?? 'STECKBRIEF', 'STECKBRIEF');
 c = c.replaceAll(AppLocalizations.of(context)?.interestsHobbies ?? 'INTERESSEN UND HOBBYS', 'INTERESSEN UND HOBBYS');
 c = c.replaceAll(AppLocalizations.of(context)?.no ?? 'Keine Angabe', 'Keine Angabe');
 c = c.replaceAll(AppLocalizations.of(context)?.male ?? 'Mann', 'Mann');
 c = c.replaceAll(AppLocalizations.of(context)?.female ?? 'Frau', 'Frau');
 c = c.replaceAll(AppLocalizations.of(context)?.gender ?? 'GESCHLECHT', 'GESCHLECHT');
 f.writeAsStringSync(c);
 print('Reverted');
}
