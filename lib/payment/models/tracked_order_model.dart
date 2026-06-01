import '../../cart/models/order_display_models.dart';
import 'payment_model.dart';

enum OrderTrackStatus { inProgress, delivered, cancelled }

class TrackedOrder {
  final String orderId;
  final DateTime placedAt;
  final int totalRupees;
  final PaalvandiPaymentMethod paymentMethod;
  final UpiAppOption? upiApp;
  final List<String> productSummaries;
  final List<OrderProductDisplay> products;
  final String deliveryOtp;
  final OrderTrackStatus status;
  final String? cancellationId;

  const TrackedOrder({
    required this.orderId,
    required this.placedAt,
    required this.totalRupees,
    required this.paymentMethod,
    this.upiApp,
    required this.productSummaries,
    required this.products,
    required this.deliveryOtp,
    this.status = OrderTrackStatus.inProgress,
    this.cancellationId,
  });

  bool get paidOnline => paymentMethod == PaalvandiPaymentMethod.payNowUpi;

  bool get canCancel => status == OrderTrackStatus.inProgress;

  bool get isCancelled => status == OrderTrackStatus.cancelled;

  String get paymentLabel => switch (paymentMethod) {
        PaalvandiPaymentMethod.payNowUpi =>
          'Paid via ${upiApp?.label ?? 'UPI'}',
        PaalvandiPaymentMethod.payAtDelivery => 'Pay at delivery (UPI QR)',
        PaalvandiPaymentMethod.none => 'Pending',
      };

  TrackedOrder copyWith({OrderTrackStatus? status, String? cancellationId}) {
    return TrackedOrder(
      orderId: orderId,
      placedAt: placedAt,
      totalRupees: totalRupees,
      paymentMethod: paymentMethod,
      upiApp: upiApp,
      productSummaries: productSummaries,
      products: products,
      deliveryOtp: deliveryOtp,
      status: status ?? this.status,
      cancellationId: cancellationId ?? this.cancellationId,
    );
  }
}
