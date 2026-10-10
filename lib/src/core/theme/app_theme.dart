import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF6E59F7);
  static const Color secondary = Color(0xFF58B7FF);
  static const Color accent = Color(0xFFF4BC3C);

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F8FF),
    );
    return base.copyWith(
      textTheme: _premiumArabicTextTheme(base.textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: secondary,
        brightness: Brightness.dark,
      ),
    );
    return base.copyWith(textTheme: _premiumArabicTextTheme(base.textTheme));
  }

  static TextTheme _premiumArabicTextTheme(TextTheme base) {
    final cairo = GoogleFonts.cairoTextTheme(base);
    final tajawal = GoogleFonts.tajawalTextTheme(base);
    return cairo.copyWith(
      bodyLarge: tajawal.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      bodyMedium: tajawal.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      bodySmall: tajawal.bodySmall?.copyWith(fontWeight: FontWeight.w500),
      labelLarge: tajawal.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: tajawal.labelMedium?.copyWith(fontWeight: FontWeight.w500),
      labelSmall: tajawal.labelSmall?.copyWith(fontWeight: FontWeight.w500),
      titleLarge: cairo.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: cairo.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: cairo.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      headlineMedium: cairo.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: cairo.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}
