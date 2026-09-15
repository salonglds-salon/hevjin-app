import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math' as math;
// dart:js_util entfernt - war ein Ueberrest der alten JS-Interop-Google-Anmeldung,
// wurde nicht mehr verwendet und haette den Android-Build zerstoert.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_logger.dart';
import '../../utils/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/language_provider.dart';
import '../splash_screen.dart';
import 'register_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_screen.dart';
import '../legal/imprint_screen.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // === MEM U ZIN ANIMATION ===
  late AnimationController _gradientCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _petalCtrl;
  final List<_Petal> _petals = [];
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  /// Nur waehrend des manuellen E-Mail-Logins true. Der Auth-Listener muss
  /// dann pausieren, weil _loginWithEmail() die Navigation selbst uebernimmt
  /// (inkl. deleted_at-Pruefung fuer die Reaktivierung).
  bool _emailLoginInProgress = false;
  bool _passwordVisible = false;
  String? _error;
  StreamSubscription<AuthState>? _authSub;
  /// Notbremse: falls der OAuth-Redirect nie stattfindet oder der Nutzer
  /// zurueckkommt, ohne dass die Seite neu geladen wird.
  Timer? _oauthTimeout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // B) Atmender Gradient (langsam, 8 Sek)
    _gradientCtrl = AnimationController(duration: const Duration(seconds: 8), vsync: this)..repeat(reverse: true);

    // C) Pulsierendes Logo (Herzschlag, 1.6 Sek)
    _pulseCtrl = AnimationController(duration: const Duration(milliseconds: 1600), vsync: this)..repeat(reverse: true);

    // A) Schwebende Rosenbluten (12 Sek Loop)
    _petalCtrl = AnimationController(duration: const Duration(seconds: 12), vsync: this)..repeat();
    final rnd = math.Random(42);
    for (int i = 0; i < 14; i++) {
      _petals.add(_Petal(
        startX: rnd.nextDouble(),
        size: 8 + rnd.nextDouble() * 14,
        speed: 0.5 + rnd.nextDouble() * 0.8,
        phase: rnd.nextDouble(),
        drift: (rnd.nextDouble() - 0.5) * 0.25,
        rotSpeed: (rnd.nextDouble() - 0.5) * 4,
        colorIndex: rnd.nextInt(3),
      ));
    }
    // Listen for OAuth redirect (Google Login only)
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      // Guard prueft _emailLoginInProgress, NICHT _isLoading: _isLoading wird
      // auch von _signInWithGoogle() gesetzt und bleibt bis zum
      // Lifecycle-Callback bzw. 8s-Timeout stehen. Kommt das signedIn-Event
      // vorher rein (Android-Deep-Link ist schneller), wurde es verworfen und
      // es gab keinen zweiten Versuch: eingeloggt, aber Welcome-Screen blieb.
      if (!mounted || _emailLoginInProgress) return;
      if (data.event == AuthChangeEvent.signedIn) {
        _handleLoginSuccess();
      }
    });
  }

  Future<void> _handleLoginSuccess() async {
    if (!mounted) return;
    _authSub?.cancel(); // Prevent double navigation
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  /// Wird aufgerufen, wenn der Nutzer zur App zurueckkehrt - z.B. nachdem er
  /// den Google-Login abgebrochen und "Zurueck" gedrueckt hat.
  /// Ohne das bliebe der Button dauerhaft deaktiviert.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetLoading();
    }
  }

  void _resetLoading() {
    _oauthTimeout?.cancel();
    _oauthTimeout = null;
    if (mounted && _isLoading) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _oauthTimeout?.cancel();
    _gradientCtrl.dispose();
    _pulseCtrl.dispose();
    _petalCtrl.dispose();
    _authSub?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientCtrl,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_gradientCtrl.value);
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFF2D2016), const Color(0xFF4A2A1C), t)!,
                  Color.lerp(const Color(0xFF3D2418), const Color(0xFF5C3A28), t)!,
                  Color.lerp(const Color(0xFF2A1E14), const Color(0xFF3A2419), 1 - t)!,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // A) Schwebende Rosenblueten
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _petalCtrl,
                      builder: (context, _) => CustomPaint(
                        painter: _PetalPainter(_petals, _petalCtrl.value),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      child: ConstrainedBox(
                        // verhindert, dass Buttons auf Tablet/Desktop quer ueber
                        // den ganzen Bildschirm gezogen werden
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                // Sprachwahl liegt als eigenes Stack-Element oben rechts (siehe unten)
                // - hier nur vertikalen Platz dafuer freihalten
                const SizedBox(height: 48),
                // C) Pulsierendes Logo mit Gold-Glow
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, child) {
                    final p = Curves.easeInOut.transform(_pulseCtrl.value);
                    return Transform.scale(
                      scale: 1.0 + p * 0.06,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE02020).withValues(alpha: 0.15 + p * 0.40),
                              blurRadius: 20 + p * 30,
                              spreadRadius: 2 + p * 8,
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset('assets/images/logo.png', width: 100, height: 100, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(color: HevjinTheme.secondary, borderRadius: BorderRadius.circular(24)),
                        child: const Icon(Icons.favorite, color: Color(0xFFE02020), size: 50),
                      ),
                    ),
                  ),
                ),
                // ---- Marken-Block: Logo + Name + Claim gehoeren zusammen ----
                const SizedBox(height: 18),
                const Text('Hevj\u00een',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(AppLocalizations.of(context)?.welcome ?? 'Partnersuche f\u00fcr \u00caziden',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60, fontSize: 14.5)),

                const SizedBox(height: 38),

                // Fehlermeldung
                if (_error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: HevjinTheme.error.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: HevjinTheme.error.withValues(alpha: 0.35)),
                    ),
                    child: Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 12.5)),
                  ),
                  const SizedBox(height: 18),
                ],
                // ---- Aktionen: beide transparent mit Rahmen ----
                // Primaer: E-Mail (etwas hellerer Rahmen = leicht betont)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _showEmailDialog(context),
                    icon: const Icon(Icons.email_outlined, size: 19),
                    label: Text(AppLocalizations.of(context)?.loginWithEmail ?? 'Mit E-Mail einloggen'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      side: const BorderSide(color: Colors.white70, width: 1.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Sekundaer: Google (dezenterer Rahmen)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _signInWithGoogle(),
                    icon: SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white70),
                              )
                            : const Text('G',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                      ),
                    ),
                    label: Text(AppLocalizations.of(context)?.continueWithGoogle ?? 'Weiter mit Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 2),

                // Hilfe-Link gehoert zu den Buttons -> direkt darunter
                TextButton(
                  onPressed: () => _showResetPasswordDialog(context),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(AppLocalizations.of(context)?.loginProblems ?? 'Probleme bei der Anmeldung?',
                      style: const TextStyle(
                          color: HevjinTheme.secondaryLight, fontSize: 13, fontWeight: FontWeight.w500)),
                ),

                const SizedBox(height: 26),

                // ---- Vertrauens-Block, visuell abgesetzt ----
                Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),
                const SizedBox(height: 18),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 14,
                  runSpacing: 10,
                  children: [
                    _badge(Icons.shield_outlined, AppLocalizations.of(context)?.anonymous ?? '100% Daten verschl\u00fcsselt'),
                    _badge(Icons.verified_outlined, AppLocalizations.of(context)?.emailVerified ?? 'E-Mail verifiziert'),
                    _badge(Icons.favorite_outline, AppLocalizations.of(context)?.onlyEzidi ?? 'Nur \u00caziden'),
                  ],
                ),
                const SizedBox(height: 20),

                // ---- Rechtliches ----
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen())),
                      child: Text(AppLocalizations.of(context)?.terms ?? 'AGB',
                          style: const TextStyle(color: Colors.white54, fontSize: 11, decoration: TextDecoration.underline)),
                    ),
                    const Text('  \u00b7  ', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                      child: Text(AppLocalizations.of(context)?.privacy ?? 'Datenschutz',
                          style: const TextStyle(color: Colors.white54, fontSize: 11, decoration: TextDecoration.underline)),
                    ),
                    const Text('  \u00b7  ', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImprintScreen())),
                      child: Text(AppLocalizations.of(context)?.imprint ?? 'Impressum',
                          style: const TextStyle(color: Colors.white54, fontSize: 11, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
                ),

                // B) Sprachwahl - fix oben rechts am Bildschirmrand,
                // ausserhalb der 400px-Inhaltsspalte
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, right: 10),
                      child: _buildLanguageSelector(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===== EMAIL DIALOG =====
  void _showEmailDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24, right: 24, top: 12),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 22),
              Text(AppLocalizations.of(context)?.loginRegister ?? 'Anmelden',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 22),

              TextField(controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _sheetField(
                  AppLocalizations.of(context)?.email ?? 'E-Mail',
                  Icons.email_outlined)),
              const SizedBox(height: 12),

              TextField(controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: _sheetField(
                  AppLocalizations.of(context)?.password ?? 'Passwort',
                  Icons.lock_outlined).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                      size: 20, color: Colors.grey.shade600),
                    onPressed: () => setModalState(
                      () => _passwordVisible = !_passwordVisible)))),

              Align(alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showResetPasswordDialog(context);
                  },
                  child: Text(AppLocalizations.of(context)?.forgotPassword ?? 'Passwort vergessen?',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700)))),
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  Navigator.pop(ctx);
                  await _loginWithEmail();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HevjinTheme.secondary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
                child: Text(AppLocalizations.of(context)?.login ?? 'Einloggen',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
              const SizedBox(height: 6),

              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const RegisterScreen()));
                },
                child: Text.rich(TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  children: [
                    TextSpan(text: AppLocalizations.of(context)?.noAccountYet ?? 'Noch kein Konto?  '),
                    TextSpan(text: AppLocalizations.of(context)?.registerShort ?? 'Registrieren',
                      style: const TextStyle(color: HevjinTheme.secondary,
                        fontWeight: FontWeight.w600)),
                  ]))),
            ],
          ),
        )),
      )),
    );
  }

  // ===== SHEET FIELD STYLE =====
  InputDecoration _sheetField(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: HevjinTheme.secondary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.2)),
        labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: HevjinTheme.secondary, fontSize: 13),
      );

  // ===== PASSWORT VERGESSEN DIALOG =====
  void _showResetPasswordDialog(BuildContext context) {
    final resetController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)?.resetPassword ?? 'Passwort zurücksetzen', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)?.resetPasswordDesc ?? 'Gib deine E-Mail ein und wir senden dir einen Link.', style: const TextStyle(color: HevjinTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(controller: resetController, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'deine@email.de', prefixIcon: Icon(Icons.email_outlined, size: 20))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final email = resetController.text.trim();
                  if (email.isEmpty) return;
                  // Beide vor dem await greifen - nach Navigator.pop(ctx) ist der
                  // Sheet-Context weg und ScaffoldMessenger.of(context) laeuft
                  // ueber einen bereits deaktivierten Element-Baum.
                  final messenger = ScaffoldMessenger.of(context);
                  final sheetNavigator = Navigator.of(ctx);
                  try {
                    await Supabase.instance.client.auth.resetPasswordForEmail(
                      email,
                      redirectTo: kIsWeb ? Uri.base.origin : 'app.hevjin://login-callback',
                    );
                    sheetNavigator.pop();
                    messenger.showSnackBar(
                      SnackBar(content: Text('Reset-Link an $email gesendet!'), backgroundColor: HevjinTheme.success),
                    );
                  } catch (e, s) {
                    AppLog.e('passwort-reset', e, s);
                    sheetNavigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Fehler beim Senden'), backgroundColor: Colors.red),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: HevjinTheme.secondary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(AppLocalizations.of(context)?.sendLink ?? 'Link senden', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: HevjinTheme.secondaryLight),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  Future<void> _loginWithEmail() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() => _error = AppLocalizations.of(context)?.errEmailPasswordRequired ?? 'Bitte E-Mail und Passwort eingeben');
      return;
    }
    _emailLoginInProgress = true;
    setState(() { _isLoading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _handleLoginSuccess();
    } catch (e) {
      _emailLoginInProgress = false;
      if (!mounted) return;
      setState(() { _isLoading = false; _error = 'Login fehlgeschlagen: ${e.toString()}'; });
    }
  }

  Widget _buildLanguageSelector(BuildContext context) {
    if (LanguageProvider.supportedLocales.length < 2) return const SizedBox.shrink();
    final langProvider = context.watch<LanguageProvider>();
    final currentCode = langProvider.locale.languageCode;
    final currentName = LanguageProvider.localeNames[currentCode] ?? 'Deutsch';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: HevjinTheme.background,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                ...LanguageProvider.supportedLocales.map((locale) {
                  final code = locale.languageCode;
                  final name = LanguageProvider.localeNames[code] ?? code;
                  final isSelected = code == currentCode;
                  return ListTile(
                    title: Text(name, style: TextStyle(color: isSelected ? HevjinTheme.secondary : HevjinTheme.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    trailing: isSelected ? const Icon(Icons.check, color: HevjinTheme.secondary) : null,
                    onTap: () {
                      langProvider.setLocale(locale);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(currentName, style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
  Future<void> _signInWithGoogle() async {
    if (_isLoading) return; // Doppelklick verhindern
    setState(() { _isLoading = true; _error = null; });

    // Notbremse: Wenn der Nutzer den Google-Login abbricht und zurueckkommt,
    // ohne dass die Seite neu geladen wird, bliebe der Button sonst
    // dauerhaft gesperrt. Nach 8 Sekunden wieder freigeben.
    _oauthTimeout?.cancel();
    _oauthTimeout = Timer(const Duration(seconds: 8), () {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    });

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        // Web: zurueck auf die Website. Android: Deep Link in die App
        // (Intent-Filter dafuer liegt in AndroidManifest.xml, Zeile 21-26).
        redirectTo: kIsWeb ? 'https://hevjin.app' : 'app.hevjin://login-callback',
      );
    } catch (e) {
      _oauthTimeout?.cancel();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Google Login fehlgeschlagen: ${e.toString()}';
        });
      }
    }
  }
}

// ===== MEM U ZIN: SCHWEBENDE ROSENBLUETEN =====
class _Petal {
  final double startX;    // 0..1 horizontale Startposition
  final double size;      // Groesse in px
  final double speed;     // Fallgeschwindigkeit
  final double phase;     // 0..1 Zeitversatz
  final double drift;     // horizontale Drift
  final double rotSpeed;  // Rotationsgeschwindigkeit
  final int colorIndex;   // 0..2 Farbvariante

  _Petal({
    required this.startX,
    required this.size,
    required this.speed,
    required this.phase,
    required this.drift,
    required this.rotSpeed,
    required this.colorIndex,
  });
}

class _PetalPainter extends CustomPainter {
  final List<_Petal> petals;
  final double t; // 0..1 Animation

  _PetalPainter(this.petals, this.t);

  // Mem u Zin Farbpalette
  static const List<Color> _colors = [
    Color(0xFFE8B4B8), // Rose (Zins Schleier)
    Color(0xFFC4562E), // Terracotta (Zins Kleid)
    Color(0xFFE02020), // Gold (Schmuck)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      // Vertikale Position (Loop von oben nach unten)
      final prog = (t * p.speed + p.phase) % 1.0;
      final y = prog * (size.height + 100) - 50;

      // Horizontale Drift (sanftes Schweben)
      final sway = math.sin((prog * 2 * math.pi * 1.5) + p.phase * 6.28) * 30;
      final x = p.startX * size.width + sway + p.drift * size.width * prog;

      // Fade in/out an den Raendern
      double opacity = 0.5;
      if (prog < 0.12) opacity *= prog / 0.12;
      if (prog > 0.85) opacity *= (1.0 - prog) / 0.15;

      final paint = Paint()
        ..color = _colors[p.colorIndex].withValues(alpha: opacity.clamp(0.0, 0.55))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(prog * p.rotSpeed * math.pi);

      // Bluetenblatt zeichnen (Tropfenform)
      final path = Path();
      final s = p.size;
      path.moveTo(0, -s * 0.5);
      path.quadraticBezierTo(s * 0.55, -s * 0.25, s * 0.42, s * 0.3);
      path.quadraticBezierTo(s * 0.2, s * 0.55, 0, s * 0.5);
      path.quadraticBezierTo(-s * 0.2, s * 0.55, -s * 0.42, s * 0.3);
      path.quadraticBezierTo(-s * 0.55, -s * 0.25, 0, -s * 0.5);
      path.close();

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PetalPainter old) => old.t != t;
}
