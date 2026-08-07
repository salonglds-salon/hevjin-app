import 'dart:io';
import 'dart:convert';

// Fixes ARB files that contain a LITERAL double-backslash unicode escape
// e.g. the 7 chars  \ \ u 0 0 f c   ->  real char 'u-umlaut'
void main() {
  final dir = Directory('lib/l10n');
  // Matches \\uXXXX  (in Dart source: two backslashes then u then 4 hex)
  final re = RegExp(r'\\\\u([0-9a-fA-F]{4})');

  int filesFixed = 0;
  int totalReps = 0;

  for (final e in dir.listSync()) {
    if (e is! File || !e.path.endsWith('.arb')) continue;

    final original = e.readAsStringSync(encoding: utf8);
    int reps = 0;

    final fixed = original.replaceAllMapped(re, (m) {
      reps++;
      return String.fromCharCode(int.parse(m.group(1)!, radix: 16));
    });

    if (reps > 0) {
      e.writeAsStringSync(fixed, encoding: utf8);
      print('FIXED (${reps}x): ${e.path.split(Platform.pathSeparator).last}');
      filesFixed++;
      totalReps += reps;
    }
  }

  print('---');
  print('Files: $filesFixed | Replacements: $totalReps');
}
