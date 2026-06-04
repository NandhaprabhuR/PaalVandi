import '../models/bulk_order_model.dart';
import '../../core/constants/mock_data.dart';

/// Abstract bulk order repository — swap for Supabase later.
abstract class BulkRepository {
  Future<List<BulkOrderModel>> fetchBulkOrders();
  Future<BulkOrderModel> markDelivered(
    String id, {
    required bool hasCollectedBalance,
    double? collectedAmount,
  });
}

class MockBulkRepository implements BulkRepository {
  final List<BulkOrderModel> _orders = List.from(MockData.bulkOrders);

  @override
  Future<List<BulkOrderModel>> fetchBulkOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_orders);
  }

  @override
  Future<BulkOrderModel> markDelivered(
    String id, {
    required bool hasCollectedBalance,
    double? collectedAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      final order = _orders[index];
      final double advancePaid = 500.0;
      
      String finalPaymentStatus;
      double finalCollected;

      if (order.paymentStatus == 'Paid') {
        finalPaymentStatus = 'Paid Fully';
        finalCollected = order.totalAmount;
      } else if (hasCollectedBalance) {
        finalPaymentStatus = 'Paid Fully';
        finalCollected = order.totalAmount;
      } else {
        finalPaymentStatus = 'Partially Paid';
        finalCollected = advancePaid + (collectedAmount ?? 0.0);
      }

      _orders[index] = order.copyWith(
        isDelivered: true,
        paymentStatus: finalPaymentStatus,
        collectedAmount: finalCollected,
        deliveryDate: DateTime.now(),
      );
      return _orders[index];
    }
    throw Exception('Bulk order not found: $id');
  }
}
