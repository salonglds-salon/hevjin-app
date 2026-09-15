// Smoke-Tests fuer Hevjin.
//
// Vorher stand hier der unveraenderte Flutter-Boilerplate-Test
// ("Counter increments smoke test"), der `MyApp` erwartete. Die App-Klasse
// heisst aber `HevjinApp` - der Test war daher nicht kompilierbar und
// `flutter test` schlug schon vor jeder Aenderung fehl.
//
// Ein Widget-Test auf HevjinApp braucht ein initialisiertes Supabase und ist
// hier nicht sinnvoll. Getestet wird deshalb, was ohne Backend laeuft.

import 'package:flutter_test/flutter_test.dart';

import 'package:hevjin/services/language_provider.dart';
import 'package:hevjin/utils/app_logger.dart';

void main() {
  group('Lokalisierung', () {
    test('App ist DE-only', () {
      // Bewusste Produktentscheidung (11.09.2026): EN wurde deaktiviert, weil
      // gemischte DE/EN-Screens schlechter sind als durchgehend Deutsch.
      // Der Sprachumschalter blendet sich bei length < 2 selbst aus - kommt
      // hier je eine Sprache dazu, erscheint er wieder in der UI.
      expect(LanguageProvider.supportedLocales.length, 1);
      expect(LanguageProvider.supportedLocales.first.languageCode, 'de');
    });
  });

  group('AppLog', () {
    test('kuerzt lange Fehlertexte und wirft nicht', () {
      // AppLog.e darf unter keinen Umstaenden selbst werfen - es laeuft in
      // den globalen Error-Handlern aus main.dart.
      expect(() => AppLog.e('test', Exception('x' * 1000)), returnsNormally);
      expect(() => AppLog.e('test', null), returnsNormally);
      expect(() => AppLog.d('test', 'nachricht'), returnsNormally);
    });
  });
}
