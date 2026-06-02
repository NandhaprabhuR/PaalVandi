import 'package:equatable/equatable.dart';

class PaymentHistoryEntry extends Equatable {
  final String transactionId;
  final String referenceNumber;
  final DateTime date;
  final int amount;
  final String method; // 'UPI' or 'Doorstep UPI QR' or 'Pay at Delivery'
  final String status; // 'Success' or 'Pending' or 'Failed'

  const PaymentHistoryEntry({
    required this.transactionId,
    required this.referenceNumber,
    required this.date,
    required this.amount,
    required this.method,
    required this.status,
  });

  @override
  List<Object?> get props => [
        transactionId,
        referenceNumber,
        date,
        amount,
        method,
        status,
      ];
}
