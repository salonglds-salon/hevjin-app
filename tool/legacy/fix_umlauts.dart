import 'dart:io';
void main() {
  final f = File('lib/screens/home/home_screen.dart');
  var c = f.readAsStringSync();
  // Fix corrupted umlauts
  c = c.replaceAll('Gespr\u00c3\u00a4che', 'Gespr\u00e4che');
  c = c.replaceAll('L\u00c3\u00b6schen', 'L\u00f6schen');
  c = c.replaceAll('hinzuf\u00c3\u00bcgen', 'hinzuf\u00fcgen');
  c = c.replaceAll('\u00c3\u009cbereinstimmung', '\u00dcbereinstimmung');
  c = c.replaceAll('\u00c3\u00bc', '\u00fc');
  c = c.replaceAll('\u00c3\u00b6', '\u00f6');
  c = c.replaceAll('\u00c3\u00a4', '\u00e4');
  c = c.replaceAll('\u00c3\u009c', '\u00dc');
  c = c.replaceAll('\u00c3\u0096', '\u00d6');
  c = c.replaceAll('\u00c3\u0084', '\u00c4');
  f.writeAsStringSync(c);
  print('Fixed umlauts');
}
