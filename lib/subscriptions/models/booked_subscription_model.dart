class BookedSubscription {
  final String planTitle;
  final DateTime bookedAt;
  final List<String> configSummary;
  final List<String> rateLines;
  final int monthlyMilkRupees;
  final int deliveryChargeRupees;
  final int monthlyBillRupees;
  final int advanceRupees;
  final int balanceOnFullPaymentRupees;
  final bool isFullyPaid;

  const BookedSubscription({
    required this.planTitle,
    required this.bookedAt,
    this.configSummary = const [],
    this.rateLines = const [],
    this.monthlyMilkRupees = 0,
    this.deliveryChargeRupees = 0,
    this.monthlyBillRupees = 0,
    this.advanceRupees = 200,
    this.balanceOnFullPaymentRupees = 0,
    this.isFullyPaid = false,
  });
}
