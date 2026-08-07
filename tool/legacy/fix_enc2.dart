import 'dart:io';
void main() {
  final f = File('lib/screens/home/home_screen.dart');
  var c = f.readAsStringSync();
  // Fix remaining double-encoded chars
  c = c.replaceAll('\u00c3\u00a9', '\u00e9');
  c = c.replaceAll('\u00c3\u00bc', '\u00fc');
  c = c.replaceAll('\u00c3\u00b6', '\u00f6');
  c = c.replaceAll('\u00c3\u00a4', '\u00e4');
  c = c.replaceAll('\u00c3\u009c', '\u00dc');
  c = c.replaceAll('\u00c3\u0084', '\u00c4');
  c = c.replaceAll('\u00c3\u0096', '\u00d6');
  c = c.replaceAll('\u00c3\u009f', '\u00df');
  c = c.replaceAll('\u00c3\u00ae', '\u00ee');
  c = c.replaceAll('\u00c2\u00ab', '\u00ab');
  c = c.replaceAll('\u00c2\u00bb', '\u00bb');
  // Fix emoji encoding (â¤ï ̧ -> real heart)
  c = c.replaceAll('\u00e2\u009d\u00a4\u00ef\u00b8\u008f', '\u2764\ufe0f');
  c = c.replaceAll('\u00e2\u009d\u00a4', '\u2764');
  f.writeAsStringSync(c);
  print('Fixed all encoding issues');
}
