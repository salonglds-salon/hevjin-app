import 'dart:io';
void main() {
  final f = File('lib/screens/profile/create_profile_screen.dart');
  var c = f.readAsStringSync();
  // Fix escaped unicode that shows as literal text
  c = c.replaceAll(r"\\u00dc, '\u00dc');
 c = c.replaceAll(r\\u00fc, '\u00fc');
 c = c.replaceAll(r\\u00f6, '\u00f6');
 c = c.replaceAll(r\\u00e4, '\u00e4');
 c = c.replaceAll(r\\u00df, '\u00df');
 c = c.replaceAll(r\\u00c4, '\u00c4');
 c = c.replaceAll(r\\u00d6, '\u00d6');
 f.writeAsStringSync(c);
 print('Fixed unicode escapes in create_profile_screen');
}
