import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/profile_service.dart';
import '../profile/create_profile_screen.dart';
import '../home/home_screen.dart';
import 'welcome_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  bool _isLoading = false;
  String? _error;
  bool _passwordVisible = false;
  bool _password2Visible = false;

  int _calculateAge() {
    if (_birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month || (now.month == _birthDate!.month && now.day < _birthDate!.day)) age--;
    return age;
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || _birthDate == null || _gender == null) {
      setState(() => _error = 'Bitte alle Pflichtfelder ausf\u00fcllen');
      return;
    }
    if (password != _password2Controller.text.trim()) {
      setState(() => _error = 'Die Passwörter stimmen nicht überein');
      return;
    }

    if (password.length < 6) {
      setState(() => _error = 'Passwort muss mindestens 6 Zeichen haben');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'birth_date': _birthDate!.toIso8601String().split('T').first,
          'gender': _gender,
        },
      );
      final user = response.user;
      if (user == null) {
        setState(() { _isLoading = false; _error = 'Registrierung fehlgeschlagen'; });
        return;
      }
      // Don't save profile yet - user needs to confirm email first
      // Profile will be created after email confirmation + first login (in Wizard)
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Show email confirmation screen
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => _EmailConfirmationScreen(email: email),
      ));
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(l?.register ?? 'Neues Konto erstellen', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(l?.welcome ?? 'Partnersuche f\u00fcr \u00caziden', style: TextStyle(color: HevjinTheme.textSecondary)),
            const SizedBox(height: 24),

            // Error
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            // Vorname
            Text('${l?.firstName ?? 'Vorname'} *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: l?.firstName ?? 'Vorname', prefixIcon: const Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),

            // Geburtsdatum
            Text('${l?.birthDate ?? 'Geburtsdatum'} *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _birthDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    _birthDate != null ? '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}' : 'Tag / Monat / Jahr',
                    style: TextStyle(color: _birthDate != null ? Colors.black87 : Colors.grey),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            // Geschlecht
            const Text('Geschlecht *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = 'male'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _gender == 'male' ? HevjinTheme.secondary : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(l?.male ?? 'Mann', style: TextStyle(color: _gender == 'male' ? Colors.white : Colors.black87, fontWeight: FontWeight.w600))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = 'female'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _gender == 'female' ? HevjinTheme.secondary : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(l?.female ?? 'Frau', style: TextStyle(color: _gender == 'female' ? Colors.white : Colors.black87, fontWeight: FontWeight.w600))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // E-Mail
            Text('${l?.email ?? 'E-Mail'} *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: 'deine@email.de', prefixIcon: const Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 16),

            // Passwort
            Text('${l?.password ?? 'Passwort'} *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                hintText: l?.password ?? 'Passwort',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, size: 20),
                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Passwort wiederholen
            Text('${l?.password ?? 'Passwort'} wiederholen *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _password2Controller,
              obscureText: !_password2Visible,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Passwort erneut eingeben',
                prefixIcon: const Icon(Icons.lock_reset_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_password2Visible ? Icons.visibility : Icons.visibility_off, size: 20),
                  onPressed: () => setState(() => _password2Visible = !_password2Visible),
                ),
                errorText: (_password2Controller.text.isNotEmpty &&
                        _password2Controller.text != _passwordController.text)
                    ? 'Passwörter stimmen nicht überein'
                    : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 48),
              ),
            ),
            if (_password2Controller.text.isNotEmpty &&
                _password2Controller.text == _passwordController.text)
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 15, color: Color(0xFF4CAF50)),
                    SizedBox(width: 6),
                    Text('Passwörter stimmen überein',
                        style: TextStyle(fontSize: 12, color: Color(0xFF4CAF50))),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HevjinTheme.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(l?.register ?? 'Registrieren', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),

            // Already have account
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l?.login ?? 'Ich habe schon ein Konto', style: TextStyle(color: HevjinTheme.secondary)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ===== EMAIL CONFIRMATION SCREEN =====
class _EmailConfirmationScreen extends StatelessWidget {
  final String email;
  const _EmailConfirmationScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 64, color: Color(0xFFE02020)),
              const SizedBox(height: 24),
              const Text('E-Mail best\u00e4tigen', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                'Wir haben eine Best\u00e4tigungs-E-Mail an\n\n$email\n\ngesendet. Bitte klicke den Link in der E-Mail um dein Konto zu aktivieren.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.auth.resend(type: OtpType.signup, email: email);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('E-Mail erneut gesendet!'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text('E-Mail erneut senden'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Zur\u00fcck zum Login', style: TextStyle(color: Color(0xFF999999))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

