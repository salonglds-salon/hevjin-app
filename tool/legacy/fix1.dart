import 'dart:io';
void main() {
  final f = File('lib/screens/home/home_screen.dart');
  var c = f.readAsStringSync();
  // Add import if not exists
  if (!c.contains('app_localizations.dart')) {
    c = c.replaceFirst("import '../../utils/theme.dart';, import '../../utils/theme.dart';\\nimport '../../l10n/app_localizations.dart';);
 }
 f.writeAsStringSync(c);
 print('Import added');
}
