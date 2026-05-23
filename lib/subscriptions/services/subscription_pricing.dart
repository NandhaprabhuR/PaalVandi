import 'package:flutter/material.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_quote_model.dart';

class SubscriptionPricing {
  static const int advanceRupees = 200;
  static const int deliveryChargeRupees = 0;
  static const int daysPerMonth = 30;

  static SubscriptionQuote build({
    required String planTitle,
    required Color backgroundColor,
    required List<String> configSummary,
    required int dailyMilkRupees,
    List<SubscriptionBillLine>? extraRateLines,
  }) {
    final monthlyMilk = dailyMilkRupees * daysPerMonth;
    final lines = <SubscriptionBillLine>[
      SubscriptionBillLine(
        label: 'Daily milk rate',
        amountRupees: dailyMilkRupees,
      ),
      SubscriptionBillLine(
        label: 'Estimated days',
        amountRupees: daysPerMonth,
      ),
      if (extraRateLines != null) ...extraRateLines,
      SubscriptionBillLine(
        label: 'Monthly milk total',
        amountRupees: monthlyMilk,
      ),
    ];

    return SubscriptionQuote(
      planTitle: planTitle,
      backgroundColor: backgroundColor,
      configSummary: configSummary,
      rateLines: lines,
      monthlyMilkRupees: monthlyMilk,
      deliveryChargeRupees: deliveryChargeRupees,
      monthlyBillRupees: monthlyMilk + deliveryChargeRupees,
      advanceRupees: advanceRupees,
    );
  }

  static int _familyDaily(String quantity, String timing) {
    const base = {
      '250ml': 28,
      '500ml': 48,
      '1L': 85,
      '1.25L': 98,
      '1.5L': 110,
      '2L': 140,
    };
    var rate = base[quantity] ?? 50;
    if (timing.contains('Both')) rate = (rate * 1.75).round();
    return rate;
  }

  static int _businessDaily(String quantity, String frequency, String timing) {
    final liters = _parseLiters(quantity);
    var rate = (liters * 18).round();
    if (frequency.contains('Twice')) rate = (rate * 1.85).round();
    if (timing.contains('Morning + Evening')) rate = (rate * 1.15).round();
    return rate.clamp(180, 2500);
  }

  static int _eventTotal(String quantity) {
    final liters = _parseLiters(quantity);
    return (liters * 55).round().clamp(550, 5500);
  }

  static int _smartDailyAverage(Map<String, String> dayQty, String timing) {
    var total = 0;
    var days = 0;
    for (final q in dayQty.values) {
      if (q == 'None') continue;
      total += _familyDaily(q, timing);
      days++;
    }
    if (days == 0) return 48;
    return (total / days).round();
  }

  static double _parseLiters(String quantity) {
    if (quantity.endsWith('L')) {
      final n = quantity.replaceAll('L', '').trim();
      return double.tryParse(n) ?? 5;
    }
    if (quantity.endsWith('ml')) {
      final n = quantity.replaceAll('ml', '').trim();
      return (double.tryParse(n) ?? 500) / 1000;
    }
    return 5;
  }

  static SubscriptionQuote family({
    required String quantity,
    required String timing,
    required List<String> options,
  }) {
    final daily = _familyDaily(quantity, timing);
    return build(
      planTitle: SubscriptionPlans.family.title,
      backgroundColor: SubscriptionPlans.family.cardTint,
      configSummary: [
        'Quantity: $quantity',
        'Timing: $timing',
        if (options.isNotEmpty) 'Options: ${options.join(', ')}',
      ],
      dailyMilkRupees: daily,
    );
  }

  static SubscriptionQuote business({
    required String quantity,
    required String frequency,
    required String timing,
    required String businessType,
  }) {
    final daily = _businessDaily(quantity, frequency, timing);
    return build(
      planTitle: SubscriptionPlans.business.title,
      backgroundColor: SubscriptionPlans.business.cardTint,
      configSummary: [
        'Quantity: $quantity',
        'Frequency: $frequency',
        'Timing: $timing',
        'Business: $businessType',
      ],
      dailyMilkRupees: daily,
    );
  }

  static SubscriptionQuote event({
    required String quantity,
    required String eventDate,
    required String eventTime,
    required String address,
    String? instructions,
  }) {
    final eventTotal = _eventTotal(quantity);
    final summary = [
      'Quantity: $quantity',
      'Date: $eventDate',
      'Time: $eventTime',
      if (address.isNotEmpty) 'Address: $address',
      if (instructions != null && instructions.isNotEmpty)
        'Notes: $instructions',
    ];
    return SubscriptionQuote(
      planTitle: SubscriptionPlans.event.title,
      backgroundColor: SubscriptionPlans.event.cardTint,
      configSummary: summary,
      rateLines: [
        SubscriptionBillLine(
          label: 'Bulk supply ($quantity)',
          amountRupees: eventTotal,
        ),
        SubscriptionBillLine(
          label: 'One-time event total',
          amountRupees: eventTotal,
        ),
      ],
      monthlyMilkRupees: eventTotal,
      deliveryChargeRupees: deliveryChargeRupees,
      monthlyBillRupees: eventTotal,
      advanceRupees: advanceRupees,
    );
  }

  static SubscriptionQuote smart({
    required Map<String, String> dayQty,
    required String timing,
  }) {
    final daily = _smartDailyAverage(dayQty, timing);
    final activeDays = dayQty.entries
        .where((e) => e.value != 'None')
        .map((e) => '${e.key}: ${e.value}')
        .toList();
    return build(
      planTitle: SubscriptionPlans.smart.title,
      backgroundColor: SubscriptionPlans.smart.cardTint,
      configSummary: [
        'Timing: $timing',
        ...activeDays,
      ],
      dailyMilkRupees: daily,
    );
  }
}
