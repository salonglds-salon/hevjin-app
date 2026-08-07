import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';
import '../splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // Phone Login
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  String _selectedCountryCode = '+49';
  
  final List<Map<String, String>> _countryCodes = [
    // Hauptl\u00e4nder Diaspora
    {'code': '+49', 'flag': '\u{1F1E9}\u{1F1EA}', 'name': 'Deutschland'},
    {'code': '+43', 'flag': '\u{1F1E6}\u{1F1F9}', 'name': '\u00d6sterreich'},
    {'code': '+41', 'flag': '\u{1F1E8}\u{1F1ED}', 'name': 'Schweiz'},
    {'code': '+44', 'flag': '\u{1F1EC}\u{1F1E7}', 'name': 'UK'},
    {'code': '+33', 'flag': '\u{1F1EB}\u{1F1F7}', 'name': 'Frankreich'},
    {'code': '+31', 'flag': '\u{1F1F3}\u{1F1F1}', 'name': 'Niederlande'},
    {'code': '+32', 'flag': '\u{1F1E7}\u{1F1EA}', 'name': 'Belgien'},
    {'code': '+46', 'flag': '\u{1F1F8}\u{1F1EA}', 'name': 'Schweden'},
    {'code': '+47', 'flag': '\u{1F1F3}\u{1F1F4}', 'name': 'Norwegen'},
    {'code': '+45', 'flag': '\u{1F1E9}\u{1F1F0}', 'name': 'D\u00e4nemark'},
    {'code': '+1', 'flag': '\u{1F1FA}\u{1F1F8}', 'name': 'USA / Kanada'},
    {'code': '+61', 'flag': '\u{1F1E6}\u{1F1FA}', 'name': 'Australien'},
    // Heimatl\u00e4nder
    {'code': '+964', 'flag': '\u{1F1EE}\u{1F1F6}', 'name': 'Irak'},
    {'code': '+963', 'flag': '\u{1F1F8}\u{1F1FE}', 'name': 'Syrien'},
    {'code': '+90', 'flag': '\u{1F1F9}\u{1F1F7}', 'name': 'T\u00fcrkei'},
    {'code': '+374', 'flag': '\u{1F1E6}\u{1F1F2}', 'name': 'Armenien'},
    {'code': '+995', 'flag': '\u{1F1EC}\u{1F1EA}', 'name': 'Georgien'},
    {'code': '+7', 'flag': '\u{1F1F7}\u{1F1FA}', 'name': 'Russland'},
    {'code': '+380', 'flag': '\u{1F1FA}\u{1F1E6}', 'name': 'Ukraine'},
    // Weitere
    {'code': '+30', 'flag': '\u{1F1EC}\u{1F1F7}', 'name': 'Griechenland'},
    {'code': '+39', 'flag': '\u{1F1EE}\u{1F1F9}', 'name': 'Italien'},
    {'code': '+34', 'flag': '\u{1F1EA}\u{1F1F8}', 'name': 'Spanien'},
  ];

  // Email Login
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HevjinTheme.background,
      appBar: AppBar(
        title: const Text('Einloggen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset('assets/images/logo.png', width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: HevjinTheme.secondary, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.favorite, color: Colors.white, size: 30),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Willkommen zurück!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // Email Login direkt (kein Tab)
          Expanded(
            child: _buildEmailTab(),
          ),
        ],
      ),
    );
  }

  // ===== PHONE TAB =====
  Widget _buildPhoneTab() {
    final auth = context.watch<AuthService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_otpSent) ...[
            const Text('Handynummer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                // Country Code Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCountryCode,
                      items: _countryCodes.map((c) => DropdownMenuItem(
                        value: c['code'],
                        child: Text('${c['flag']} ${c['code']}', style: const TextStyle(fontSize: 14)),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedCountryCode = val!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Phone Number Field
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '170 1234567',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : () async {
                  final phone = '$_selectedCountryCode${_phoneController.text.trim()}';
                  final success = await auth.sendOtp(phone);
                  if (success) setState(() => _otpSent = true);
                },
                child: auth.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Code senden'),
              ),
            ),
          ] else ...[
            const Text('Verifizierungscode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            Text('Code an $_selectedCountryCode${_phoneController.text} gesendet', style: TextStyle(fontSize: 12, color: HevjinTheme.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(hintText: '• • • • • •', counterText: ''),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : () async {
                  final success = await auth.verifyOtp(
                    _phoneController.text.trim(),
                    _otpController.text.trim(),
                  );
                  if (success && mounted) {
                    Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (_) => const SplashScreen()), (route) => false);
                  }
                },
                child: auth.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Verifizieren'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _otpSent = false),
                child: const Text('Andere Nummer verwenden'),
              ),
            ),
          ],

          // Error
          if (auth.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HevjinTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: HevjinTheme.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(auth.errorMessage!, style: TextStyle(color: HevjinTheme.error, fontSize: 12))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===== EMAIL TAB =====
  Widget _buildEmailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('E-Mail', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'deine@email.de',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 14),

          const Text('Passwort', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              hintText: 'Dein Passwort',
              prefixIcon: const Icon(Icons.lock_outlined, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, size: 20, color: HevjinTheme.textSecondary),
                onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _loginWithEmail,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Einloggen'),
            ),
          ),
          const SizedBox(height: 12),

          // Forgot Password
          Center(
            child: TextButton(
              onPressed: _resetPassword,
              child: Text('Passwort vergessen?', style: TextStyle(color: HevjinTheme.secondary, fontSize: 13)),
            ),
          ),

          // Error
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HevjinTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: HevjinTheme.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: TextStyle(color: HevjinTheme.error, fontSize: 12))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===== EMAIL LOGIN =====
  Future<void> _loginWithEmail() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Bitte E-Mail und Passwort eingeben');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const SplashScreen()), (route) => false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Login fehlgeschlagen. Bitte prüfe deine Daten.';
      });
    }
  }

  // ===== RESET PASSWORD =====
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Bitte gib zuerst deine E-Mail ein');
      return;
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwort-Reset E-Mail an $email gesendet'),
            backgroundColor: HevjinTheme.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'Fehler beim Senden der Reset-E-Mail');
    }
  }
}
