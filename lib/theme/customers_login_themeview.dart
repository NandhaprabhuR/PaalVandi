import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomersLoginThemeView {
  static const Color primaryBlue = Color(0xFF0056B3); // The deep blue from the design
  static const Color textDark = Color(0xFF1D3557);
  static const Color textGrey = Color(0xFF6C757D);
  static const Color borderColor = Color(0xFFDEE2E6);

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
}
