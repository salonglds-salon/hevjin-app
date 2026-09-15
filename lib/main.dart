import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'utils/url_strategy_stub.dart'
    if (dart.library.js_interop) 'utils/url_strategy_web.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'services/language_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_logger.dart';
import 'utils/theme.dart';
import 'l10n/app_localizations.dart';

void main() {
  // Alles in eine guarded Zone: faengt auch Fehler, die in Futures/Timers
  // ausserhalb des Widget-Trees hochkommen und sonst lautlos verschwinden.
  runZonedGuarded(_bootstrap, (error, stack) {
    AppLog.e('uncaught', error, stack);
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Framework-Fehler (build/layout/paint) zentral protokollieren.
  // Ohne das landen sie im Release nur im ErrorWidget, ohne Log-Spur.
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLog.e('flutter', details.exception, details.stack);
    previousOnError?.call(details);
  };

  // Fehler, die die Engine ausserhalb des Flutter-Frameworks meldet.
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLog.e('platform', error, stack);
    return true; // als behandelt markieren, damit die App nicht abbricht
  };

  // Statt grauem Kasten (Release-Default) eine lesbare Info anzeigen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 52, color: Color(0xFFE02020)),
          const SizedBox(height: 16),
          const Text(
            'Hier ist etwas schiefgelaufen',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 10),
          const Text(
            'Bitte lade die Seite neu. Falls es weiterhin auftritt, melde dich bei hevjinsupport@gmail.com.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF6B6B6B)),
          ),
          const SizedBox(height: 18),
          Text(
            details.exceptionAsString(),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9A9A9A)),
          ),
        ],
      ),
    );
  };
  configureUrlStrategy();

  await _initSupabaseAndRun();
}

/// Initialisiert Supabase und startet die App.
///
/// Getrennt von [_bootstrap], damit der Retry-Button die einmaligen
/// Setup-Schritte (Binding, Error-Handler, UrlStrategy) NICHT erneut ausfuehrt.
Future<void> _initSupabaseAndRun() async {
  // Supabase-Init darf main() nicht mitreissen. Ohne Netz (Flugmodus, schlechtes
  // Mobilfunknetz beim Kaltstart) wirft initialize() - vorher endete das in einem
  // weissen Screen ohne jede Erklaerung. Ein Play-Reviewer haette genau das gesehen.
  try {
    await Supabase.initialize(
      url: 'https://lrmoxfjuhqesjoxjkftw.supabase.co',
      publishableKey: 'sb_publishable_MyJQ6C3_P5ZyD34dr0u2vw_GvnTNch9',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
  } catch (error, stack) {
    AppLog.e('supabase-init', error, stack);
    runApp(const _StartupFailureApp());
    return;
  }

  runApp(const HevjinApp());
}

/// Wird nur angezeigt, wenn Supabase beim Start nicht erreichbar war.
/// Gibt dem Nutzer einen Retry statt eines weissen Screens.
class _StartupFailureApp extends StatefulWidget {
  const _StartupFailureApp();

  @override
  State<_StartupFailureApp> createState() => _StartupFailureAppState();
}

class _StartupFailureAppState extends State<_StartupFailureApp> {
  bool _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return; // Doppel-Taps blocken
    setState(() => _retrying = true);
    await _initSupabaseAndRun();
    // Wenn der Retry erfolgreich war, hat runApp() den Tree bereits ersetzt.
    // Nur falls dieses Widget noch lebt, den Button wieder freigeben.
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: HevjinTheme.lightTheme,
      home: Scaffold(
        backgroundColor: const Color(0xFF8B3A0F),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 56, color: Color(0xFFD4952B)),
                const SizedBox(height: 20),
                const Text(
                  'Keine Verbindung',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hevj\u00een konnte den Server nicht erreichen. '
                  'Pr\u00fcfe deine Internetverbindung und starte die App neu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, height: 1.5, color: Colors.white70),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: _retrying ? null : _retry,
                  icon: _retrying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_retrying ? 'Verbinde...' : 'Erneut versuchen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4952B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HevjinApp extends StatelessWidget {
  const HevjinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProfileService()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, _) {
          return MaterialApp(
            title: 'Hevj\u00een',
            debugShowCheckedModeBanner: false,
            theme: HevjinTheme.lightTheme,
            locale: langProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageProvider.supportedLocales,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
