import 'dart:math' as math;
import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double screenWidth(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double screenHeight(BuildContext context) => MediaQuery.sizeOf(context).height;

  // Baseline device size (standard modern phone width and height)
  static const double _baselineWidth = 390.0;
  static const double _baselineHeight = 844.0;

  // Scale a design dimension proportionally with the device's width
  static double scaleWidth(BuildContext context, double value) {
    final width = screenWidth(context);
    return (width / _baselineWidth) * value;
  }

  // Scale a design dimension proportionally with the device's height
  static double scaleHeight(BuildContext context, double value) {
    final height = screenHeight(context);
    return (height / _baselineHeight) * value;
  }

  // Scaled font size with constraints to prevent extremely tiny/huge text on odd screens
  static double scaledFontSize(BuildContext context, double baseFontSize) {
    final width = screenWidth(context);
    final scale = width / _baselineWidth;
    // Dampen the scale factor slightly (0.75 weight) so text remains readable
    final factor = 1.0 + (scale - 1.0) * 0.75;
    return (baseFontSize * factor).clamp(baseFontSize * 0.85, baseFontSize * 1.4);
  }

  // Scaled spacing (padding/margins) with safe clamps
  static double horizontalPadding(BuildContext context, {double baseValue = 16.0}) {
    final scaled = scaleWidth(context, baseValue);
    return scaled.clamp(12.0, 32.0);
  }

  static double verticalPadding(BuildContext context, {double baseValue = 16.0}) {
    final scaled = scaleHeight(context, baseValue);
    return scaled.clamp(8.0, 32.0);
  }

  // Responsive layout values
  static double scaledValue(BuildContext context, double value, {double? min, double? max}) {
    final scaled = scaleWidth(context, value);
    if (min != null && max != null) return scaled.clamp(min, max);
    if (min != null) return math.max(min, scaled);
    if (max != null) return math.min(max, scaled);
    return scaled;
  }

  // Breakpoints
  static bool isSmallScreen(BuildContext context) => screenWidth(context) < 360;
  static bool isMediumScreen(BuildContext context) => screenWidth(context) >= 360 && screenWidth(context) < 600;
  static bool isTablet(BuildContext context) => screenWidth(context) >= 600;
}
