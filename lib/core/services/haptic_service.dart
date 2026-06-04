import 'package:flutter/services.dart';

/// Centralized haptic feedback service with enable/disable support.
class HapticService {
  static bool _enabled = true;

  static bool get isEnabled => _enabled;

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Light — selection, tab switches, toggles
  static void light() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Medium — delivered button, important actions
  static void medium() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Heavy — success completion, major milestones
  static void heavy() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Selection click — for taps on cards, list items
  static void selectionClick() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }
}
