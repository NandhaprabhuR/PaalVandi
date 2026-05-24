import 'package:flutter/material.dart';
import 'booked_subscription_model.dart';

class SubscriptionBillLine {
  final String label;
  final int amountRupees;

  const SubscriptionBillLine({
    required this.label,
    required this.amountRupees,
  });
}

class SubscriptionQuote {
  final String planTitle;
  final Color backgroundColor;
  final List<String> configSummary;
  final List<SubscriptionBillLine> rateLines;
  final int monthlyMilkRupees;
  final int deliveryChargeRupees;
  final int monthlyBillRupees;
  final int advanceRupees;
  final int balanceOnFullPaymentRupees;

  const SubscriptionQuote({
    required this.planTitle,
    required this.backgroundColor,
    required this.configSummary,
    required this.rateLines,
    required this.monthlyMilkRupees,
    this.deliveryChargeRupees = 0,
    required this.monthlyBillRupees,
    this.advanceRupees = 200,
  }) : balanceOnFullPaymentRupees = monthlyBillRupees - advanceRupees;

  BookedSubscription toBooking({bool payFull = false}) {
    return BookedSubscription(
      planTitle: planTitle,
      bookedAt: DateTime.now(),
      configSummary: configSummary,
      rateLines: rateLines.map((l) {
        if (l.label == 'Estimated days') {
          return '${l.label}: ${l.amountRupees} days';
        }
        return '${l.label}: ₹${l.amountRupees}';
      }).toList(),
      monthlyMilkRupees: monthlyMilkRupees,
      deliveryChargeRupees: deliveryChargeRupees,
      monthlyBillRupees: monthlyBillRupees,
      advanceRupees: payFull ? monthlyBillRupees : advanceRupees,
      balanceOnFullPaymentRupees: payFull ? 0 : balanceOnFullPaymentRupees,
      isFullyPaid: payFull,
    );
  }
}
