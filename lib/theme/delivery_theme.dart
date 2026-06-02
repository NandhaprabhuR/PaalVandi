import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryTheme {
  // Swiggy & Zomato Inspired Neon Orange & Deep Charcoal Theme
  static const Color primaryOrange = Color(0xFFFF5200);   // Neon Delivery Orange
  static const Color accentAmber = Color(0xFFFFB300);    // Warm Amber
  static const Color bgDark = Color(0xFF0C0E12);         // Rich Midnight Dark
  static const Color cardDark = Color(0xFF171B22);       // Charcoal Dark Card
  static const Color borderDark = Color(0xFF232A34);     // Deep Border Charcoal
  
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B9BB4);
  static const Color textMuted = Color(0xFF53627C);

  static const Color statusOnline = Color(0xFF00E676);    // Vibrant Online Green
  static const Color statusOffline = Color(0xFFFF3D00);   // Vibrant Offline Red
  static const Color gpayBlue = Color(0xFF1A73E8);        // Tactile Controls GPay Blue

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: bgDark,
      cardColor: cardDark,
      dividerColor: borderDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryOrange,
        secondary: accentAmber,
        surface: cardDark,
        onSurface: textLight,
        error: statusOffline,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.montserrat(color: textLight, fontWeight: FontWeight.w800),
        headlineMedium: GoogleFonts.montserrat(color: textLight, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.montserrat(color: textLight, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.montserrat(color: textLight, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.montserrat(color: textSecondary, fontWeight: FontWeight.w400),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        iconTheme: IconThemeData(color: textLight),
      ),
    );
  }
}
