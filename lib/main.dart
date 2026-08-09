import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'utils/url_strategy_stub.dart'
    if (dart.library.js_interop) 'utils/url_strategy_web.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'services/language_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';
import 'utils/app_mode.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // PWA/Homescreen-Modus einmalig erkennen (manifest start_url = "/?pwa=1")
  AppMode.init();

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
  
  await Supabase.initialize(
    url: 'https://lrmoxfjuhqesjoxjkftw.supabase.co',
    anonKey: 'sb_publishable_MyJQ6C3_P5ZyD34dr0u2vw_GvnTNch9',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  runApp(const HevjinApp());
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
