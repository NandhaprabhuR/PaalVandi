import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomersLoginThemeView {
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

  static bool get isDarkMode => false;

  static const Color primaryBlue = Color(0xFF0056B3); // The deep blue from the design
  static Color get textDark => isDarkMode ? Colors.white : const Color(0xFF1D3557);
  static Color get textGrey => isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF6C757D);
  static Color get borderColor => isDarkMode ? primaryBlue : const Color(0xFFDEE2E6);
  static const Color sectionHeadingRed = Color(0xFFD32F2F);
  /// Volume / quantity labels (ml, L, g).
  static const Color quantityAccent = Color(0xFF0288D1);
  /// Price amounts on product and cart cards.
  static const Color priceAccent = Color(0xFF0056B3);

  static Color get cardBackgroundColor => isDarkMode ? Colors.black : Colors.white;
  static Color get scaffoldBackgroundColor => isDarkMode ? Colors.black : Colors.white;

  static TextStyle get titleStyle => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  static TextStyle get subtitleStyle => GoogleFonts.montserrat(
    fontSize: 14,
    color: textGrey,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get buttonTextStyle => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get hintStyle => GoogleFonts.montserrat(
    fontSize: 16,
    color: textGrey,
  );

  static TextStyle get featureTextStyle => GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.2,
  );

  static TextStyle get sectionHeadingStyle => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  static TextStyle get brandTitleStyle => GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: const Color(0xFF2E7D32),
    letterSpacing: 2.0,
  );

  static TextStyle get brandTaglineStyle => GoogleFonts.montserrat(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
    letterSpacing: 0.8,
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackgroundColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.black,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.06),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
