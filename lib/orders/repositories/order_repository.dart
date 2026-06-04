import '../models/daily_order_model.dart';
import '../../core/constants/mock_data.dart';

/// Abstract order repository — swap for Supabase later.
abstract class OrderRepository {
  Future<List<DailyOrderModel>> fetchTodayOrders();
  Future<DailyOrderModel> updateOrderStatus(String orderId, String newStatus);
}

class MockOrderRepository implements OrderRepository {
  final List<DailyOrderModel> _orders = List.from(MockData.dailyOrders);

  @override
  Future<List<DailyOrderModel>> fetchTodayOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_orders);
  }

  @override
  Future<DailyOrderModel> updateOrderStatus(String orderId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      final order = _orders[index];
      String? updatedPaymentStatus;
      if (newStatus == 'Delivered' &&
          (order.paymentStatus == 'Pending' || order.paymentStatus == 'Pay At Delivery')) {
        updatedPaymentStatus = 'Paid';
      }
      _orders[index] = order.copyWith(
        status: newStatus,
        paymentStatus: updatedPaymentStatus,
      );
      return _orders[index];
    }
    throw Exception('Order not found: $orderId');
  }
}
