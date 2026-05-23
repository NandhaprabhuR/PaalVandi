import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomersLoginThemeView {
  static const Color primaryBlue = Color(0xFF0056B3); // The deep blue from the design
  static const Color textDark = Color(0xFF1D3557);
  static const Color textGrey = Color(0xFF6C757D);
  static const Color borderColor = Color(0xFFDEE2E6);
  static const Color sectionHeadingRed = Color(0xFFD32F2F);
  /// Volume / quantity labels (ml, L, g).
  static const Color quantityAccent = Color(0xFF0288D1);
  /// Price amounts on product and cart cards.
  static const Color priceAccent = Color(0xFF0056B3);

  static TextStyle titleStyle = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  static TextStyle subtitleStyle = GoogleFonts.montserrat(
    fontSize: 14,
    color: textGrey,
    fontWeight: FontWeight.w400,
  );

  static TextStyle buttonTextStyle = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle hintStyle = GoogleFonts.montserrat(
    fontSize: 16,
    color: textGrey,
  );

  static TextStyle featureTextStyle = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.2,
  );

  static TextStyle sectionHeadingStyle = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  static TextStyle brandTitleStyle = GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: primaryBlue,
    letterSpacing: 2.0,
  );

  static TextStyle brandTaglineStyle = GoogleFonts.montserrat(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
    letterSpacing: 0.8,
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: primaryBlue.withValues(alpha: 0.25),
      width: 1.2,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
