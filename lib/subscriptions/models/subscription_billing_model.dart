import 'package:equatable/equatable.dart';

class SubscriptionBillingModel extends Equatable {
  final String id;
  final String customerName;
  final String phone;
  final String subscriptionType; // 'Family' | 'Business' | 'Smart' | 'Event'
  final double ratePerLiter;
  final double morningQty;
  final double eveningQty;
  final Map<int, double>? weekdayQuantities; // Weekday index (1 = Monday, ..., 7 = Sunday) for Smart Subscription
  final double advancePaid;
  final String paymentStatus; // 'Paid' | 'Partial' | 'Unpaid'

  const SubscriptionBillingModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.subscriptionType,
    required this.ratePerLiter,
    this.morningQty = 0.0,
    this.eveningQty = 0.0,
    this.weekdayQuantities,
    this.advancePaid = 0.0,
    this.paymentStatus = 'Unpaid',
  });

  double get dailyQuantity => morningQty + eveningQty;

  SubscriptionBillingModel copyWith({
    String? customerName,
    String? phone,
    String? subscriptionType,
    double? ratePerLiter,
    double? morningQty,
    double? eveningQty,
    Map<int, double>? weekdayQuantities,
    double? advancePaid,
    String? paymentStatus,
  }) {
    return SubscriptionBillingModel(
      id: id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      ratePerLiter: ratePerLiter ?? this.ratePerLiter,
      morningQty: morningQty ?? this.morningQty,
      eveningQty: eveningQty ?? this.eveningQty,
      weekdayQuantities: weekdayQuantities ?? this.weekdayQuantities,
      advancePaid: advancePaid ?? this.advancePaid,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerName,
        phone,
        subscriptionType,
        ratePerLiter,
        morningQty,
        eveningQty,
        weekdayQuantities,
        advancePaid,
        paymentStatus,
      ];
}
