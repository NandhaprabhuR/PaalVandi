import 'package:equatable/equatable.dart';

class DeliveryLedgerEntry extends Equatable {
  final String id;
  final String subscriptionId;
  final DateTime date;
  final String status; // 'Delivered' | 'Vacation' | 'Paused' | 'Customer Skip' | 'Company Skip' | 'Failed Delivery'
  final double quantityMorning;
  final double quantityEvening;
  final double ratePerLiter;

  const DeliveryLedgerEntry({
    required this.id,
    required this.subscriptionId,
    required this.date,
    required this.status,
    required this.quantityMorning,
    required this.quantityEvening,
    required this.ratePerLiter,
  });

  double get totalQuantity => quantityMorning + quantityEvening;
  double get calculatedCost => status == 'Delivered' ? totalQuantity * ratePerLiter : 0.0;

  DeliveryLedgerEntry copyWith({
    String? status,
    double? quantityMorning,
    double? quantityEvening,
    double? ratePerLiter,
  }) {
    return DeliveryLedgerEntry(
      id: id,
      subscriptionId: subscriptionId,
      date: date,
      status: status ?? this.status,
      quantityMorning: quantityMorning ?? this.quantityMorning,
      quantityEvening: quantityEvening ?? this.quantityEvening,
      ratePerLiter: ratePerLiter ?? this.ratePerLiter,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subscriptionId,
        date,
        status,
        quantityMorning,
        quantityEvening,
        ratePerLiter,
      ];
}
