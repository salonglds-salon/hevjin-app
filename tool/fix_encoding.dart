import 'dart:io';
import 'dart:convert';

// Fixes double-encoded UTF-8 (mojibake): "Ã¤" -> "ä"
void main() {
  // Map: broken 2-char sequence -> correct char
  final map = <String, String>{
    '\u00C3\u00A4': '\u00E4', // ae
    '\u00C3\u00B6': '\u00F6', // oe
    '\u00C3\u00BC': '\u00FC', // ue
    '\u00C3\u0084': '\u00C4', // Ae
    '\u00C3\u0096': '\u00D6', // Oe
    '\u00C3\u009C': '\u00DC', // Ue
    '\u00C3\u009F': '\u00DF', // sz
    '\u00C3\u00AA': '\u00EA', // e-circumflex
    '\u00C3\u008A': '\u00CA', // E-circumflex
    '\u00C3\u00AE': '\u00EE', // i-circumflex
    '\u00C3\u008E': '\u00CE', // I-circumflex
    '\u00C3\u00A9': '\u00E9', // e-acute
    '\u00C3\u00A8': '\u00E8', // e-grave
    '\u00C3\u00A2': '\u00E2', // a-circumflex
  };

  int fixedFiles = 0;
  int totalReplacements = 0;

  final dir = Directory('lib');
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    final original = entity.readAsStringSync(encoding: utf8);
    var content = original;
    int fileReps = 0;

    map.forEach((broken, correct) {
      final count = broken.allMatches(content).length;
      if (count > 0) {
        content = content.replaceAll(broken, correct);
        fileReps += count;
      }
    });

    if (content != original) {
      entity.writeAsStringSync(content, encoding: utf8);
      print('FIXED (${fileReps}x): ${entity.path}');
      fixedFiles++;
      totalReplacements += fileReps;
    }
  }

  print('---');
  print('Files fixed: $fixedFiles | Replacements: $totalReplacements');
}
