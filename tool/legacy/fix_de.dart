import 'dart:io';
import 'dart:convert';
void main() {
  final f = File('lib/l10n/app_de.arb');
  final d = json.decode(f.readAsStringSync()) as Map<String,dynamic>;
  d['back'] = 'Zur\u00fcck';
  d['skip'] = '\u00dcberspringen';
  d['createProfile'] = 'Profil erstellen';
  d['aboutMe'] = '\u00dcber mich';
  d['aboutYou'] = '\u00dcber dich';
  d['educationLevel'] = 'Bildungsabschluss';
  d['delete'] = 'L\u00f6schen';
  f.writeAsStringSync(JsonEncoder.withIndent('  ').convert(d));
  print('DE fixed');
}
