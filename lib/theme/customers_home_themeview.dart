import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomersHomeThemeView {
  static const Color headerSkyBlue = Color(0xFF7EC8E8);
  static const Color headerIconColor = Color(0xFF2D3436);
  static const Color searchIconBlue = Color(0xFF7EC8E8);
  static const Color cardColor = Colors.white;

  static TextStyle appBarTextStyle = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle productTitleStyle = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle bodyTextStyle = GoogleFonts.montserrat(
    fontSize: 14,
    color: Color(0xFF6C757D),
    fontWeight: FontWeight.w400,
  );

  static TextStyle searchHintStyle = GoogleFonts.montserrat(
    fontSize: 14,
    color: Color(0xFFADB5BD),
    fontWeight: FontWeight.w400,
  );
}
