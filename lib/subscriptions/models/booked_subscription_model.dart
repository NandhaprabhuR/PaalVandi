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
  final String status; // 'Active' | 'Paused' | 'Expiring Soon' | 'Cancelled'
  final DateTime? pauseStartDate;
  final DateTime? pauseEndDate;

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
    this.status = 'Active',
    this.pauseStartDate,
    this.pauseEndDate,
  });

  BookedSubscription copyWith({
    String? planTitle,
    DateTime? bookedAt,
    List<String>? configSummary,
    List<String>? rateLines,
    int? monthlyMilkRupees,
    int? deliveryChargeRupees,
    int? monthlyBillRupees,
    int? advanceRupees,
    int? balanceOnFullPaymentRupees,
    bool? isFullyPaid,
    String? status,
    DateTime? pauseStartDate,
    DateTime? pauseEndDate,
  }) {
    return BookedSubscription(
      planTitle: planTitle ?? this.planTitle,
      bookedAt: bookedAt ?? this.bookedAt,
      configSummary: configSummary ?? this.configSummary,
      rateLines: rateLines ?? this.rateLines,
      monthlyMilkRupees: monthlyMilkRupees ?? this.monthlyMilkRupees,
      deliveryChargeRupees: deliveryChargeRupees ?? this.deliveryChargeRupees,
      monthlyBillRupees: monthlyBillRupees ?? this.monthlyBillRupees,
      advanceRupees: advanceRupees ?? this.advanceRupees,
      balanceOnFullPaymentRupees: balanceOnFullPaymentRupees ?? this.balanceOnFullPaymentRupees,
      isFullyPaid: isFullyPaid ?? this.isFullyPaid,
      status: status ?? this.status,
      pauseStartDate: pauseStartDate ?? this.pauseStartDate,
      pauseEndDate: pauseEndDate ?? this.pauseEndDate,
    );
  }
}
