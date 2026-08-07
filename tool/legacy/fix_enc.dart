import 'dart:io';
void main() {
  final f = File('lib/screens/home/home_screen.dart');
  var c = f.readAsStringSync();
  // Fix double-encoded UTF-8 chars
  c = c.replaceAll('\u00c3\u00ae', '\u00ee');
  c = c.replaceAll('\u00c3\u00bc', '\u00fc');
  c = c.replaceAll('\u00c3\u00b6', '\u00f6');
  c = c.replaceAll('\u00c3\u00a4', '\u00e4');
  c = c.replaceAll('\u00c3\u009c', '\u00dc');
  c = c.replaceAll('\u00c3\u0096', '\u00d6');
  c = c.replaceAll('\u00c3\u0084', '\u00c4');
  c = c.replaceAll('\u00c3\u009f', '\u00df');
  f.writeAsStringSync(c);
  print('Fixed all double-encoded umlauts');
}
