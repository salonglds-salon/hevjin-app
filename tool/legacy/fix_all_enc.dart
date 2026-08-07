import 'dart:io';
void main() {
  for (final path in [
    'lib/screens/home/home_screen.dart',
    'lib/screens/profile/create_profile_screen.dart',
    'lib/screens/auth/welcome_screen.dart',
  ]) {
    final f = File(path);
    if (!f.existsSync()) continue;
    var c = f.readAsStringSync();
    var changed = false;
    // Fix all known double-encoded UTF8 patterns
    final fixes = {
      '\u00c3\u00bc': '\u00fc',
      '\u00c3\u00a4': '\u00e4',
      '\u00c3\u00b6': '\u00f6',
      '\u00c3\u009c': '\u00dc',
      '\u00c3\u0084': '\u00c4',
      '\u00c3\u0096': '\u00d6',
      '\u00c3\u009f': '\u00df',
      '\u00c3\u00ae': '\u00ee',
      '\u00c3\u00a9': '\u00e9',
      '\u00c2\u00ab': '\u00ab',
      '\u00c2\u00bb': '\u00bb',
    };
    fixes.forEach((bad, good) {
      if (c.contains(bad)) { c = c.replaceAll(bad, good); changed = true; }
    });
    if (changed) { f.writeAsStringSync(c); print('Fixed: \$path'); }
    else { print('OK: \$path'); }
  }
}
