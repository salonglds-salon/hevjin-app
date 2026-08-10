import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../splash_screen.dart';

/// Wird angezeigt, wenn der Nutzer ueber den Passwort-Reset-Link kommt.
/// Supabase loggt den Nutzer durch den Link automatisch ein
/// (AuthChangeEvent.passwordRecovery) -> hier setzt er das neue Passwort.
class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _pw1 = TextEditingController();
  final _pw2 = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  String? _error;

  static const _brownDark = Color(0xFF2D2016);
  static const _brownLight = Color(0xFF5C3A28);
  static const _accent = Color(0xFFE02020);
  static const _accentSoft = Color(0xFFFF8A80);
  static const _okGreen = Color(0xFF6FCF6F);

  @override
  void initState() {
    super.initState();
    _pw1.addListener(_onChanged);
    _pw2.addListener(_onChanged);
  }

  void _onChanged() => setState(() => _error = null);

  bool get _lengthOk => _pw1.text.length >= 6;
  bool get _matchOk => _pw1.text.isNotEmpty && _pw1.text == _pw2.text;
  bool get _canSubmit => _lengthOk && _matchOk && !_loading;

  Future<void> _save() async {
    if (!_canSubmit) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth
          .updateUser(UserAttributes(password: _pw1.text));
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Passwort ge\u00e4ndert'),
          content: const Text(
              'Dein neues Passwort ist aktiv. Du kannst dich ab jetzt damit anmelden.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Weiter', style: TextStyle(color: _accent)),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message.contains('should be different')
            ? 'Bitte w\u00e4hle ein anderes Passwort als das alte.'
            : (e.message.toLowerCase().contains('session') ||
                    e.message.toLowerCase().contains('expired'))
                ? 'Der Link ist abgelaufen. Bitte fordere einen neuen Reset-Link an.'
                : e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'Speichern fehlgeschlagen. Pr\u00fcfe deine Verbindung und versuche es erneut.';
      });
    }
  }

  @override
  void dispose() {
    _pw1.dispose();
    _pw2.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, bool obscure, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _accentSoft, width: 1.6),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white54),
        onPressed: toggle,
      ),
    );
  }

  Widget _rule(String text, bool ok) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(children: [
          Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16, color: ok ? _okGreen : Colors.white38),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  fontSize: 12.5, color: ok ? _okGreen : Colors.white54)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_brownDark, _brownLight],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset('assets/images/logo.png',
                            width: 88, height: 88, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('Neues Passwort setzen',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 10),
                    const Text(
                        'Vergib jetzt ein neues Passwort f\u00fcr dein Hevj\u00een-Konto.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, height: 1.5, color: Colors.white70)),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _pw1,
                      obscureText: _obscure1,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec('Neues Passwort', _obscure1,
                          () => setState(() => _obscure1 = !_obscure1)),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _pw2,
                      obscureText: _obscure2,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _save(),
                      decoration: _dec('Passwort wiederholen', _obscure2,
                          () => setState(() => _obscure2 = !_obscure2)),
                    ),
                    const SizedBox(height: 14),
                    _rule('Mindestens 6 Zeichen', _lengthOk),
                    _rule('Beide Eingaben stimmen \u00fcberein', _matchOk),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: _accentSoft.withOpacity(0.5)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline,
                              size: 18, color: _accentSoft),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_error!,
                                style: const TextStyle(
                                    fontSize: 13, color: _accentSoft)),
                          ),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 26),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _canSubmit ? _save : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          disabledBackgroundColor: Colors.white24,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.2, color: Colors.white))
                            : const Text('Passwort speichern',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              await Supabase.instance.client.auth.signOut();
                              if (!context.mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const SplashScreen()),
                                (route) => false,
                              );
                            },
                      child: const Text('Abbrechen',
                          style: TextStyle(color: Colors.white54)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
