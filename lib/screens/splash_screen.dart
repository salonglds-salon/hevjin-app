import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../utils/theme.dart';
import 'auth/welcome_screen.dart';
import 'home/home_screen.dart';
import 'profile/create_profile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    bool hasNavigated = false;
    
    // Listen for auth state changes (handles OAuth redirect)
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted || hasNavigated) return;
      final event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        hasNavigated = true;
        _navigateAfterLogin();
      } else if (event == AuthChangeEvent.initialSession) {
        // Initial session check - if user exists, navigate
        if (data.session != null) {
          hasNavigated = true;
          _navigateAfterLogin();
        } else {
          // No session - wait a bit more for potential OAuth redirect
          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted || hasNavigated) return;
            final user = Supabase.instance.client.auth.currentUser;
            if (user != null) {
              hasNavigated = true;
              _navigateAfterLogin();
            } else {
              hasNavigated = true;
              _goTo(const WelcomeScreen());
            }
          });
        }
      }
    });

    // Fallback timeout - if no auth event fires within 5 seconds, go to welcome
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || hasNavigated) return;
      hasNavigated = true;
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _navigateAfterLogin();
      } else {
        _goTo(const WelcomeScreen());
      }
    });
  }

  Future<void> _navigateAfterLogin() async {
    if (!mounted) return;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) { _goTo(const WelcomeScreen()); return; }

      final profile = context.read<ProfileService>();
      await profile.fetchProfile();

      if (profile.isDeactivated) {
        // Navigate to reactivation screen
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ReactivationScreen()),
          (route) => false,
        );
        return;
      }
      
      if (profile.hasProfile) {
        _goTo(const HomeScreen());
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        await profile.fetchProfile();
        if (profile.hasProfile) {
          _goTo(const HomeScreen());
        } else {
          _goTo(CreateProfileScreen(startPage: 0, userId: userId));
        }
      }
    } catch (e) {
      _goTo(const WelcomeScreen());
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goTo(Widget screen) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: HevjinTheme.secondary.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Hevjîn',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dein Weg zur Liebe',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== REACTIVATION SCREEN =====
class ReactivationScreen extends StatelessWidget {
  const ReactivationScreen();

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
              const Icon(Icons.warning_amber_rounded, size: 64, color: Color(0xFFE02020)),
              const SizedBox(height: 24),
              const Text('Account deaktiviert', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                'Dein Account wurde gel\u00f6scht.\n\nDu hast 14 Tage Zeit ihn zu reaktivieren. Danach werden alle Daten unwiderruflich entfernt.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    final userId = Supabase.instance.client.auth.currentUser?.id;
                    if (userId != null) {
                      await Supabase.instance.client.from('profiles').update({'deleted_at': null}).eq('id', userId);
                    }
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Ja, Account reaktivieren', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                    );
                  }
                },
                child: const Text('Nein, abmelden', style: TextStyle(color: Color(0xFF999999))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

