import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HevjinTheme {
  // \u00cazidische Flagge: Rot, Gold, Wei\u00df
  static const Color primary = Color(0xFF1A1A1A);       // Schwarz (Text)
  static const Color secondary = Color(0xFFE02020);     // Rot (Akzent)
  static const Color secondaryLight = Color(0xFFFF8A80); // Hellrot (auf dunklem Grund)
  static const Color accent = Color(0xFFA01C1C);        // Weinrot (Flagge-Rot)
  static const Color background = Color(0xFFFFFFFF);    // Reinwei\u00df
  static const Color surface = Color(0xFFFFFFFF);       // Wei\u00df
  static const Color cardBg = Color(0xFFFAFAFA);        // Sehr helles Grau
  static const Color textPrimary = Color(0xFF1A1A1A);   // Schwarz
  static const Color textSecondary = Color(0xFF6B6B6B); // Neutrales Grau
  static const Color success = Color(0xFF4CAF50);       // Gr\u00fcn
  static const Color error = Color(0xFFA01C1C);         // Weinrot
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: secondary.withOpacity(0.4)),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: secondary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.6)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: secondary.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5F5F5),
        selectedColor: secondary.withOpacity(0.15),
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
