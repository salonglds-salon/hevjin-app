import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('de');
  
  Locale get locale => _locale;
  
  LanguageProvider() {
    _loadSavedLocale();
  }
  
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_language') ?? 'de';
    _locale = Locale(code);
    notifyListeners();
  }
  
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', locale.languageCode);
  }
  
  static const supportedLocales = [
    Locale('de'),
    Locale('en'),
    Locale('tr'),
    Locale('ar'),
    Locale('fa'),
    Locale('ru'),
    Locale('fr'),
    Locale('nl'),
    Locale('sv'),
    Locale('hy'),
    Locale('ka'),
  ];
  
  static const localeNames = {
    'de': '\u{1F1E9}\u{1F1EA} Deutsch',
    'en': '\u{1F1EC}\u{1F1E7} English',
    'tr': '\u{1F1F9}\u{1F1F7} T\u00fcrk\u00e7e',
    'ar': '\u{1F1EE}\u{1F1F6} Arabic',
    'fa': '\u{1F1EE}\u{1F1F7} Farsi',
    'ru': '\u{1F1F7}\u{1F1FA} Russkij',
    'fr': '\u{1F1EB}\u{1F1F7} Fran\u00e7ais',
    'nl': '\u{1F1F3}\u{1F1F1} Nederlands',
    'sv': '\u{1F1F8}\u{1F1EA} Svenska',
    'hy': '\u{1F1E6}\u{1F1F2} Hayeren',
    'ka': '\u{1F1EC}\u{1F1EA} Kartuli',
  };
}
