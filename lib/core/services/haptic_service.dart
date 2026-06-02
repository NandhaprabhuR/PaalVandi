import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticService {
  static const String hapticsKey = 'paalvandi_haptics_enabled';
  static const String pushKey = 'paalvandi_push_enabled';
  static const String orderKey = 'paalvandi_order_enabled';
  static const String remindersKey = 'paalvandi_reminders_enabled';
  static const String promoKey = 'paalvandi_promo_enabled';

  static bool hapticsEnabled = true;
  static bool pushEnabled = true;
  static bool orderEnabled = true;
  static bool remindersEnabled = true;
  static bool promoEnabled = true;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      hapticsEnabled = prefs.getBool(hapticsKey) ?? true;
      pushEnabled = prefs.getBool(pushKey) ?? true;
      orderEnabled = prefs.getBool(orderKey) ?? true;
      remindersEnabled = prefs.getBool(remindersKey) ?? true;
      promoEnabled = prefs.getBool(promoKey) ?? true;
    } catch (_) {
      hapticsEnabled = true;
      pushEnabled = true;
      orderEnabled = true;
      remindersEnabled = true;
      promoEnabled = true;
    }
  }

  static Future<void> setEnabled(bool enabled) async {
    hapticsEnabled = enabled;
    await savePreference(hapticsKey, enabled);
  }

  static Future<void> savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {}
  }

  /// Light Impact:Bottom nav tab, quantity change, button selectors, toggles, dropdowns
  static Future<void> lightImpact() async {
    if (!hapticsEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium Impact: Add to Cart, Save Profile, Subscribe, Continue, Confirm, Pickup, Address, Claim
  static Future<void> mediumImpact() async {
    if (!hapticsEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy Impact: Warning dialogs or heavy actions
  static Future<void> heavyImpact() async {
    if (!hapticsEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Success Feedback: Dynamic dual tap (PhonePay/GPay payment success style)
  static Future<void> success() async {
    if (!hapticsEnabled) return;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }

  /// Warning Feedback: Double medium tap (Warning/Confirm/Cancel style)
  static Future<void> warning() async {
    if (!hapticsEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// Selection Feedback: Date/Time picker dial click, quantity picker click
  static Future<void> selection() async {
    if (!hapticsEnabled) return;
    await HapticFeedback.selectionClick();
  }
}
