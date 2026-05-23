import 'package:flutter/material.dart';

class SubscriptionPlan {
  final IconData icon;
  final Color cardTint;
  final String title;
  final String description;
  final List<String> features;

  const SubscriptionPlan({
    required this.icon,
    required this.cardTint,
    required this.title,
    required this.description,
    required this.features,
  });
}

class SubscriptionPlans {
  static const family = SubscriptionPlan(
    icon: Icons.home_outlined,
    cardTint: Color(0xFFE8F2FA),
    title: 'Family Subscription',
    description: 'Daily milk delivery for homes and apartments',
    features: [
      'Fresh daily delivery',
      'Morning / Evening options',
      'Pause anytime',
    ],
  );

  static const business = SubscriptionPlan(
    icon: Icons.storefront_outlined,
    cardTint: Color(0xFFFFF0E0),
    title: 'Business Subscription',
    description: 'Hotels • Tea Shops • Cafes • Bakeries • Restaurants',
    features: [
      'Bulk delivery',
      'Daily recurring supply',
      'Multiple delivery schedules',
    ],
  );

  static const event = SubscriptionPlan(
    icon: Icons.celebration_outlined,
    cardTint: Color(0xFFF0E8F8),
    title: 'Event Subscription',
    description: 'Bulk milk supply for functions and events',
    features: [
      'Weddings',
      'Temple functions',
      'Birthday events',
      'Catering',
    ],
  );

  static const smart = SubscriptionPlan(
    icon: Icons.auto_awesome_outlined,
    cardTint: Color(0xFFE6F2EA),
    title: 'Smart Subscription',
    description: 'Flexible quantity plans',
    features: [
      'Different quantities on different days',
      'Morning + Evening combinations',
      'Fully customizable',
    ],
  );

  static const all = [family, business, event, smart];
}
