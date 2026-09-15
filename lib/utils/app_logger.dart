import 'package:flutter/foundation.dart';

/// Zentrales Logging fuer Hevjin.
///
/// WARUM: `print()` schreibt auch im Release-Build in die Browser-Console
/// bzw. ins Android-Log. Die App verarbeitet Art.-9-DSGVO-Daten
/// (Kaste, Stamm, Bio) - die duerfen dort nie landen.
///
/// Regeln:
/// - [d] / [i] laufen NUR im Debug-Build (kDebugMode).
/// - [e] laeuft immer, gibt aber ausschliesslich Fehlertyp + Nachricht aus,
///   niemals Nutzdaten.
/// - Nie ganze Maps/Profile loggen. Statt `log(profile)` -> `log(profile.id)`.
class AppLog {
  AppLog._();

  static const String _prefix = '[Hevjin]';

  /// Debug-Detail. Nur im Debug-Build sichtbar.
  static void d(String tag, Object? message) {
    if (kDebugMode) {
      debugPrint('$_prefix [$tag] $message');
    }
  }

  /// Info. Nur im Debug-Build sichtbar.
  static void i(String tag, Object? message) {
    if (kDebugMode) {
      debugPrint('$_prefix [$tag] $message');
    }
  }

  /// Fehler. Auch im Release sichtbar, aber ohne Nutzdaten.
  ///
  /// [error] wird auf Typ + Kurznachricht reduziert, damit z. B. eine
  /// PostgrestException nicht die gesamte Response mitschleppt.
  static void e(String tag, Object? error, [StackTrace? stack]) {
    final summary = _summarize(error);
    if (kDebugMode) {
      debugPrint('$_prefix [$tag] FEHLER: $summary');
      if (stack != null) debugPrintStack(stackTrace: stack, maxFrames: 12);
    } else {
      debugPrint('$_prefix [$tag] FEHLER: $summary');
    }
  }

  /// Kuerzt Fehlerobjekte auf eine loggbare Zeile.
  static String _summarize(Object? error) {
    if (error == null) return 'unbekannt';
    final type = error.runtimeType.toString();
    var text = error.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length > 200) text = '${text.substring(0, 200)}...';
    return text.startsWith(type) ? text : '$type: $text';
  }
}
