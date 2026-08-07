import 'dart:io';
void main() {
  final f = File('lib/screens/profile/create_profile_screen.dart');
  var c = f.readAsStringSync();
  c = c.replaceAll('Fast fertig!', '\u00dcber mich');
  c = c.replaceAll('\u00dc' + 'ber dich', '\u00dcber dich');
  c = c.replaceAll('Ueber mich', '\u00dcber mich');
  c = c.replaceAll('Zurueck', 'Zur\u00fcck');
  f.writeAsStringSync(c);
  print('Done');
}
