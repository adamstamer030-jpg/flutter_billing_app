import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF2F2F7);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFB00020);

  // الـ font بس للنصوص — مش للأيقونات
  static TextTheme get _baseTextTheme => const TextTheme();

  static TextTheme get textTheme => _baseTextTheme.copyWith(
    displayLarge:   GoogleFonts.ibmPlexSans(fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium:  GoogleFonts.ibmPlexSans(fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall:   GoogleFonts.ibmPlexSans(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge:  GoogleFonts.ibmPlexSans(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.ibmPlexSans(fontSize: 28, fontWeight: FontWeight.bold),
    headlineSmall:  GoogleFonts.ibmPlexSans(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge:     GoogleFonts.ibmPlexSans(fontSize: 22, fontWeight: FontWeight.bold),
    titleMedium:    GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall:     GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge:      GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
    bodyMedium:     GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall:      GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge:     GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.bold),
    labelMedium:    GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall:     GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w400),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.ibmPlexSans(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}
