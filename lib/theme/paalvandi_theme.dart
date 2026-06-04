import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PaalVandi branded theme matching the customer app's premium dairy identity.
/// Configured for full-black AMOLED dark mode with professional contrasts and high visibility.
class PaalvandiTheme {
  // ─── Primary Brand Colors ───────────────────────────────────
  static const Color primaryBlue = Color(0xFF1E88E5); // Vibrant Blue for Dark Theme
  static const Color primaryBlueDark = Color(0xFF1565C0);
  static const Color accentGreen = Color(0xFF4CAF50); // Vibrant Green
  static const Color accentAmber = Color(0xFFFBC02D);

  // ─── Backgrounds ───────────────────────────────────────────
  static const Color bgCream = Color(0xFFFAFAFA); // Premium Soft Off-White Background
  static const Color bgWhite = Color(0xFFFFFFFF); // Pure Solid White
  static const Color bgLight = Color(0xFFF3F4F6); // Soft Accent Background

  // ─── Card & Surface ────────────────────────────────────────
  static const Color cardWhite = Color(0xFFFFFFFF); // Solid Pure White Cards
  static const Color cardBorder = Color(0xFF000000); // Premium bold black card border
  static const Color cardBorderLight = Color(0xFF000000);
  static const Color surfaceGrey = Color(0xFFF9FAFB);

  // ─── Text ──────────────────────────────────────────────────
  static const Color textDark = Color(0xFF111827); // Deep Charcoal for maximum contrast
  static const Color textSecondary = Color(0xFF4B5563); // Medium Slate for details
  static const Color textMuted = Color(0xFF9CA3AF); // Soft gray for subtext
  static const Color textWhite = Color(0xFFFFFFFF); // Keep white text for buttons/badges

  // ─── Status ────────────────────────────────────────────────
  static const Color statusSuccess = Color(0xFF10B981); // Emerald Green
  static const Color statusWarning = Color(0xFFF59E0B); // Amber Warning
  static const Color statusError = Color(0xFFEF4444); // Red Error
  static const Color statusInfo = Color(0xFF3B82F6); // Blue Info
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusPaused = Color(0xFF6B7280);

  // ─── Delivery Specific ─────────────────────────────────────
  static const Color deliveredGreen = Color(0xFF059669);
  static const Color assignedBlue = Color(0xFF2563EB);
  static const Color preparingAmber = Color(0xFFD97706);
  static const Color outForDeliveryOrange = Color(0xFFEA580C);

  // ─── Misc ──────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFF3F4F6);
  static const Color shimmerHighlight = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFE5E7EB);

  // ─── Card Decoration ───────────────────────────────────────
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.5),
      );

  static BoxDecoration get cardDecorationSoft => BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderLight, width: 1.5),
      );

  static BoxDecoration statusBadgeDecoration(Color color) => BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      );

  // ─── Theme Data ────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light, // Set base brightness to Light
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: bgCream,
      cardColor: cardWhite,
      dividerColor: dividerColor,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentGreen,
        surface: cardWhite,
        onSurface: textDark,
        error: statusError,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.montserrat(
            color: textDark, fontWeight: FontWeight.w800, fontSize: 28),
        headlineMedium: GoogleFonts.montserrat(
            color: textDark, fontWeight: FontWeight.bold, fontSize: 22),
        titleLarge: GoogleFonts.montserrat(
            color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
        titleMedium: GoogleFonts.montserrat(
            color: textDark, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: GoogleFonts.montserrat(
            color: textDark, fontWeight: FontWeight.w500, fontSize: 14),
        bodyMedium: GoogleFonts.montserrat(
            color: textSecondary, fontWeight: FontWeight.w400, fontSize: 13),
        bodySmall: GoogleFonts.montserrat(
            color: textMuted, fontWeight: FontWeight.w400, fontSize: 12),
        labelLarge: GoogleFonts.montserrat(
            color: textWhite, fontWeight: FontWeight.bold, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgCream,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.montserrat(
          color: textDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textMuted,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: textWhite,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
