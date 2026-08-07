import 'dart:async';
import 'dart:math' as math;
// dart:js_util entfernt - war ein Ueberrest der alten JS-Interop-Google-Anmeldung,
// wurde nicht mehr verwendet und haette den Android-Build zerstoert.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/language_provider.dart';
import '../splash_screen.dart';
import '../home/home_screen.dart';
import '../profile/create_profile_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_screen.dart';
import '../legal/imprint_screen.dart';
import 'package:provider/provider.dart';
import '../../services/profile_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  // === MEM U ZIN ANIMATION ===
  late AnimationController _gradientCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _petalCtrl;
  final List<_Petal> _petals = [];
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _iAmGender = 'male'; // Ich bin
  String _searchGender = 'female'; // Ich suche
  bool _isLoading = false;
  bool _passwordVisible = false;
  String? _error;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();

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
      if (!mounted || _isLoading) return; // Don't trigger if manual login is in progress
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

  @override
  void dispose() {
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
                // Sprachwahl oben rechts - nimmt keine eigene Zeile mehr ein
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildLanguageSelector(context),
                ),
                const SizedBox(height: 26),
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
                              color: const Color(0xFFE02020).withOpacity(0.15 + p * 0.40),
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
                      color: HevjinTheme.error.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: HevjinTheme.error.withOpacity(0.35)),
                    ),
                    child: Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 12.5)),
                  ),
                  const SizedBox(height: 18),
                ],

                // ---- Aktionen ----
                // Primaer: E-Mail (Markenfarbe)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showEmailDialog(context),
                    icon: const Icon(Icons.email_outlined, size: 19),
                    label: Text(AppLocalizations.of(context)?.loginWithEmail ?? 'Mit E-Mail einloggen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE02020),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Sekundaer: Google (weiss - Google-Branding-konform, kein Blau-Bruch)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _signInWithGoogle(),
                    icon: const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: Text('G',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
                      ),
                    ),
                    label: Text(AppLocalizations.of(context)?.continueWithGoogle ?? 'Weiter mit Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1F1F1F),
                      elevation: 0,
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
                Container(height: 1, color: Colors.white.withOpacity(0.10)),
                const SizedBox(height: 18),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 14,
                  runSpacing: 10,
                  children: [
                    _badge(Icons.shield_outlined, AppLocalizations.of(context)?.anonymous ?? '100% Anonym'),
                    _badge(Icons.verified_outlined, AppLocalizations.of(context)?.emailVerified ?? 'E-Mail Verifiziert'),
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
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen())),
                      child: const Text('AGB',
                          style: TextStyle(color: Colors.white54, fontSize: 11, decoration: TextDecoration.underline)),
                    ),
                    const Text('  \u00b7  ', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                      child: const Text('Datenschutz',
                          style: TextStyle(color: Colors.white54, fontSize: 11, decoration: TextDecoration.underline)),
                    ),
                    const Text('  \u00b7  ', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImprintScreen())),
                      child: const Text('Impressum',
                          style: TextStyle(color: Colors.white54, fontSize: 11, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)?.loginRegister ?? 'Anmelden / Registrieren', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Text(AppLocalizations.of(context)?.email ?? 'E-Mail', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'deine@email.de', prefixIcon: Icon(Icons.email_outlined, size: 20))),
            const SizedBox(height: 14),

            Text(AppLocalizations.of(context)?.password ?? 'Passwort', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: _passwordController, obscureText: !_passwordVisible,
              decoration: InputDecoration(hintText: AppLocalizations.of(context)?.password ?? 'Passwort', prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                suffixIcon: IconButton(icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, size: 20),
                  onPressed: () => setModalState(() => _passwordVisible = !_passwordVisible)))),
            const SizedBox(height: 20),

            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  Navigator.pop(ctx);
                  await _loginWithEmail();
                },
                style: ElevatedButton.styleFrom(backgroundColor: HevjinTheme.secondary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(AppLocalizations.of(context)?.login ?? 'Einloggen', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),

            // Register Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: HevjinTheme.secondary)),
                child: Text(AppLocalizations.of(context)?.register ?? 'Neues Konto erstellen', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HevjinTheme.secondary)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      )),
    );
  }

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
            Text(AppLocalizations.of(context)?.resetPasswordDesc ?? 'Gib deine E-Mail ein und wir senden dir einen Link.', style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 13)),
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
                  try {
                    await Supabase.instance.client.auth.resetPasswordForEmail(email);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reset-Link an $email gesendet!'), backgroundColor: HevjinTheme.success),
                    );
                  } catch (e) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
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


  Widget _genderOption(String value, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? HevjinTheme.secondary : Colors.grey.shade300),
          color: selected ? HevjinTheme.secondary.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? HevjinTheme.secondary : Colors.grey.shade400, width: 2),
                color: selected ? HevjinTheme.secondary : Colors.transparent,
              ),
              child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
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
      setState(() => _error = 'Bitte E-Mail und Passwort eingeben');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _handleLoginSuccess();
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Login fehlgeschlagen: ${e.toString()}'; });
    }
  }
  Future<void> _registerWithEmail() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() => _error = 'Bitte E-Mail und Passwort eingeben');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _error = 'Passwort muss mindestens 6 Zeichen haben');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      // Versuche IMMER erst Login
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Login erfolgreich - check if deactivated
        setState(() => _isLoading = false);
        if (mounted) {
          // Check deleted_at before navigating
          final uid = Supabase.instance.client.auth.currentUser?.id;
          if (uid != null) {
            final profileData = await Supabase.instance.client
                .from('profiles').select('deleted_at').eq('id', uid).maybeSingle();
            if (profileData != null && profileData['deleted_at'] != null) {
              // Account is deactivated - go directly to reactivation screen
              Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const ReactivationScreen()), (route) => false);
              return;
            }
          }
          // Normal login - go to splash (which goes to home)
          Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const SplashScreen()), (route) => false);
        }
        return;
      } on AuthException catch (e) {
        if (e.message.contains('not confirmed')) {
          setState(() { _isLoading = false; _error = 'Bitte bestï¿½tige erst deine E-Mail (Check dein Postfach)'; });
          return;
        }
        if (e.message.contains('Invalid login')) {
          // Prï¿½fe ob Email schon registriert ist
          // Supabase hat leider kein "check if exists" ï¿½ wir versuchen signUp
          final response = await Supabase.instance.client.auth.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          // Wenn identities leer ? Account existiert schon (falsches Passwort)
          if (response.user?.identities == null || response.user!.identities!.isEmpty) {
            setState(() { _isLoading = false; _error = 'Diese E-Mail ist bereits registriert. Falsches Passwort? Nutze "Mitglieder-Login" ? "Passwort vergessen"'; });
            return;
          }

          // Neuer Account erstellt ? Email-Dialog zeigen
          setState(() => _isLoading = false);
        }
      }

      setState(() => _isLoading = false);

      if (mounted) {
        // Zeige Bestï¿½tigungs-Dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    color: HevjinTheme.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read, size: 36, color: HevjinTheme.success),
                ),
                const SizedBox(height: 20),
                const Text('E-Mail gesendet!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  'Wir haben dir eine Bestï¿½tigungs-E-Mail an\n${_emailController.text.trim()}\ngesendet.\n\nBitte klicke auf den Link in der E-Mail um dein Konto zu aktivieren.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HevjinTheme.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Verstanden'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Registrierung fehlgeschlagen: ${e.toString()}'; });
    }
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final currentCode = langProvider.locale.languageCode;
    final currentName = LanguageProvider.localeNames[currentCode] ?? 'Deutsch';
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFFFFFFFF),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                ...LanguageProvider.supportedLocales.map((locale) {
                  final code = locale.languageCode;
                  final name = LanguageProvider.localeNames[code] ?? code;
                  final isSelected = code == currentCode;
                  return ListTile(
                    title: Text(name, style: TextStyle(color: isSelected ? HevjinTheme.secondary : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    trailing: isSelected ? Icon(Icons.check, color: HevjinTheme.secondary) : null,
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
          color: Colors.white.withOpacity(0.1),
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
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://hevjin.app',
      );
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Google Login fehlgeschlagen: ${e.toString()}'; });
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
        ..color = _colors[p.colorIndex].withOpacity(opacity.clamp(0.0, 0.55))
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
