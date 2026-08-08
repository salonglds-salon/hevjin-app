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
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
