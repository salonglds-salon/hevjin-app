import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  /// Send OTP to phone number
  Future<bool> sendOtp(String phone) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabase.auth.signInWithOtp(phone: phone);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Fehler beim Senden: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP code
  Future<bool> verifyOtp(String phone, String code) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabase.auth.verifyOTP(
        phone: phone,
        token: code,
        type: OtpType.sms,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Falscher Code. Bitte erneut versuchen.';
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
}
