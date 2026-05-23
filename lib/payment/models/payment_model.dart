import 'package:equatable/equatable.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';

enum PaalvandiPaymentMethod { none, payNowUpi, payAtDelivery }

enum UpiAppOption { gpay, phonepe, paytm, bhim }

enum PaymentFlowStatus { idle, processing, success, failure }

class OrderSummaryLine extends Equatable {
  final String label;
  final int amountRupees;

  const OrderSummaryLine(this.label, this.amountRupees);

  @override
  List<Object> get props => [label, amountRupees];
}

class PaymentModel extends Equatable {
  final PaalvandiPaymentMethod selectedMethod;
  final UpiAppOption selectedUpiApp;
  final PaymentFlowStatus status;
  final List<OrderSummaryLine> summaryLines;
  final int totalRupees;
  final String? errorMessage;

  const PaymentModel({
    this.selectedMethod = PaalvandiPaymentMethod.none,
    this.selectedUpiApp = UpiAppOption.gpay,
    this.status = PaymentFlowStatus.idle,
    this.summaryLines = const [],
    this.totalRupees = 0,
    this.errorMessage,
  });

  factory PaymentModel.fromCart(CartViewModel cart) {
    final lines = <OrderSummaryLine>[];
    var depositTotal = 0;

    for (final item in cart.items) {
      final milkLine = item.milkPriceRupees * item.count;
      final qtySuffix = item.count > 1 ? ' ×${item.count}' : '';
      lines.add(
        OrderSummaryLine(
          '${item.productName} ${item.quantity}$qtySuffix',
          milkLine,
        ),
      );
      if (item.hasDeposit) {
        depositTotal += item.totalDepositRupees;
      }
    }

    if (depositTotal > 0) {
      lines.add(OrderSummaryLine('Glass Bottle Deposit', depositTotal));
    }

    lines.add(
      OrderSummaryLine(
        'Delivery Charge',
        cart.deliveryChargeRupeesApplied,
      ),
    );

    return PaymentModel(
      summaryLines: lines,
      totalRupees: cart.toPayRupees,
    );
  }

  String get formattedTotal => '₹$totalRupees';

  PaymentModel copyWith({
    PaalvandiPaymentMethod? selectedMethod,
    UpiAppOption? selectedUpiApp,
    PaymentFlowStatus? status,
    List<OrderSummaryLine>? summaryLines,
    int? totalRupees,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentModel(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      selectedUpiApp: selectedUpiApp ?? this.selectedUpiApp,
      status: status ?? this.status,
      summaryLines: summaryLines ?? this.summaryLines,
      totalRupees: totalRupees ?? this.totalRupees,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        selectedMethod,
        selectedUpiApp,
        status,
        summaryLines,
        totalRupees,
        errorMessage,
      ];
}

extension UpiAppOptionUi on UpiAppOption {
  String get label => switch (this) {
        UpiAppOption.gpay => 'Google Pay',
        UpiAppOption.phonepe => 'PhonePe',
        UpiAppOption.paytm => 'Paytm',
        UpiAppOption.bhim => 'BHIM',
      };
}
