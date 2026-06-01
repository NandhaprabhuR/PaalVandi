import 'package:flutter/foundation.dart';
import '../../home/models/home_catalog_data.dart';
import '../../payment/models/payment_model.dart';
import '../../payment/models/tracked_order_model.dart';
import '../../profile/models/bottle_wallet_model.dart';
import '../models/bottle_history_model.dart';
import '../models/cart_models.dart';
import '../models/order_display_models.dart';
import '../models/order_history_model.dart';
import '../models/product_review.dart';
import '../../core/app_id_generator.dart';

class CartViewModel extends ChangeNotifier {
  static const int deliveryChargeRupees = 15;

  final List<CartLineItem> items = [];
  final List<OrderHistoryEntry> completedOrders = [];
  final BottleWalletStats walletStats = const BottleWalletStats();
  bool showAddedToCartBar = false;
  TrackedOrder? activeTrackedOrder;
  final Map<String, TrackedOrder> trackedOrders = {};
  final List<BottleHistoryEntry> placedBottleHistory = [];
  final Set<String> bottleReturnRequestedOrderIds = {};

  final List<ProductReview> productReviews = [
    ProductReview(
      userName: 'Aanya',
      userEmoji: '👩‍🦰',
      rating: 5,
      comment: 'Super fresh milk delivered early morning! The quality is amazing.',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ProductReview(
      userName: 'Rahul',
      userEmoji: '🧔',
      rating: 4,
      comment: 'Very thick and pure. No water mixed at all. Recommended!',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ProductReview(
      userName: 'Karthik',
      userEmoji: '👳',
      rating: 5,
      comment: 'Outstanding delivery service. Best organic milk in town.',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ProductReview(
      userName: 'Pooja',
      userEmoji: '👱‍♀️',
      rating: 4,
      comment: 'Extremely fresh and healthy. Reminds me of farm-fresh milk.',
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  void addProductReview(ProductReview review) {
    productReviews.insert(0, review);
    notifyListeners();
  }

  static String deliveryOtpForOrderId(String orderId) {
    return (orderId.hashCode.abs() % 10000).toString().padLeft(4, '0');
  }

  TrackedOrder? trackedOrderFor(String orderId) {
    if (trackedOrders.containsKey(orderId)) {
      return trackedOrders[orderId];
    }
    final index = allOrderHistory.indexWhere((e) => e.id == orderId);
    if (index != -1) {
      final entry = allOrderHistory[index];
      final mockTracked = TrackedOrder(
        orderId: entry.id,
        placedAt: entry.orderedAt,
        totalRupees: entry.totalRupees,
        paymentMethod: PaalvandiPaymentMethod.payAtDelivery,
        productSummaries: entry.displayProducts.map((p) => p.titleLine).toList(),
        products: entry.displayProducts,
        deliveryOtp: deliveryOtpForOrderId(entry.id),
        status: entry.isCancelled ? OrderTrackStatus.cancelled : OrderTrackStatus.delivered,
        cancellationId: entry.cancellationId,
      );
      trackedOrders[orderId] = mockTracked;
      return mockTracked;
    }
    return null;
  }

  bool canTrackOrder(String orderId) {
    final order = trackedOrders[orderId];
    return order != null && order.status == OrderTrackStatus.inProgress;
  }

  /// Bottles from past deliveries not yet returned.
  int get walletPendingBottles => walletStats.pendingBottles;

  /// Deposit bottles in the current cart (will add to pending after delivery).
  int get cartDepositBottleCount => items
      .where((item) => item.hasDeposit)
      .fold(0, (sum, item) => sum + item.count);

  /// Badge on cart screen bottle icon: wallet pending + cart deposit bottles.
  int get pendingBottlesCount => walletPendingBottles + cartDepositBottleCount;

  int get itemsSubtotalRupees =>
      items.fold(0, (sum, item) => sum + item.lineTotalRupees);

  int get deliveryChargeRupeesApplied =>
      items.isEmpty ? 0 : deliveryChargeRupees;

  int get toPayRupees => itemsSubtotalRupees + deliveryChargeRupeesApplied;

  int get cartTotalRupees => toPayRupees;

  int get totalProductCount =>
      items.fold(0, (sum, item) => sum + item.count);

  void addItem(CartLineItem item) {
    items.add(item);
    showAddedToCartBar = true;
    notifyListeners();
  }

  int lineIndexFor(String productName, String quantity) {
    return items.indexWhere(
      (i) => i.productName == productName && i.quantity == quantity,
    );
  }

  int countInCart(String productName, String quantity) {
    final index = lineIndexFor(productName, quantity);
    if (index < 0) return 0;
    return items[index].count;
  }

  void addFromHome(String productName, HomeProductItem item) {
    final index = lineIndexFor(productName, item.quantity);
    if (index >= 0) {
      incrementCount(index);
      return;
    }
    addItem(
      CartLineItem(
        productName: productName,
        quantity: item.quantity,
        milkPriceRupees: item.priceRupees,
        deliveryMethod: DeliveryMethod.depositBottle,
        bottleDepositRupees: CartLineItem.glassBottleDepositRupees,
      ),
    );
  }

  void decrementFromHome(String productName, String quantity) {
    final index = lineIndexFor(productName, quantity);
    if (index < 0) return;
    if (items[index].count > 1) {
      decrementCount(index);
    } else {
      removeAt(index);
    }
  }

  void dismissAddedToCartBar() {
    if (!showAddedToCartBar) return;
    showAddedToCartBar = false;
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    notifyListeners();
  }

  void incrementCount(int index) {
    if (index < 0 || index >= items.length) return;
    items[index] = items[index].copyWith(count: items[index].count + 1);
    notifyListeners();
  }

  void decrementCount(int index) {
    if (index < 0 || index >= items.length) return;
    if (items[index].count <= 1) return;
    items[index] = items[index].copyWith(count: items[index].count - 1);
    notifyListeners();
  }

  void updateVariant(int index, String quantity, int milkPriceRupees) {
    if (index < 0 || index >= items.length) return;
    items[index] = items[index].copyWith(
      quantity: quantity,
      milkPriceRupees: milkPriceRupees,
    );
    notifyListeners();
  }

  void updateDeliveryMethod(int index, DeliveryMethod method) {
    if (index < 0 || index >= items.length) return;
    final item = items[index];
    items[index] = item.copyWith(
      deliveryMethod: method,
      clearBottleDeposit: method == DeliveryMethod.bringMyContainer,
      bottleDepositRupees: method == DeliveryMethod.depositBottle
          ? CartLineItem.glassBottleDepositRupees
          : null,
    );
    notifyListeners();
  }

  List<OrderHistoryEntry> get allOrderHistory => [
        ...completedOrders,
        ...OrderHistoryData.sampleOrders(),
      ];

  void completeOrder({
    PaalvandiPaymentMethod paymentMethod = PaalvandiPaymentMethod.payAtDelivery,
    UpiAppOption? upiApp,
  }) {
    if (items.isEmpty) return;
    final snapshot = List<CartLineItem>.from(items);
    final orderTotal = toPayRupees;
    final id = AppIdGenerator.generate5CharId();
    final placedAt = DateTime.now();

    completedOrders.insert(
      0,
      OrderHistoryEntry.fromCartItems(
        id: id,
        orderedAt: placedAt,
        items: snapshot,
        deliveryChargeRupees: deliveryChargeRupeesApplied,
        paymentMethod: paymentMethod,
        upiApp: upiApp,
      ),
    );

    final productDisplays = orderProductsFromCartItems(snapshot);
    final tracked = TrackedOrder(
      orderId: id,
      placedAt: placedAt,
      totalRupees: orderTotal,
      paymentMethod: paymentMethod,
      upiApp: upiApp,
      productSummaries: snapshot
          .map((i) => '${i.productName} ${i.quantity} ×${i.count}')
          .toList(),
      products: productDisplays,
      deliveryOtp: deliveryOtpForOrderId(id),
      status: OrderTrackStatus.inProgress,
    );
    trackedOrders[id] = tracked;
    activeTrackedOrder = tracked;

    for (final item in snapshot) {
      if (!item.hasDeposit) continue;
      placedBottleHistory.insert(
        0,
        BottleHistoryEntry(
          orderId: id,
          date: placedAt,
          productName: item.productName,
          quantity: '${item.quantity} ×${item.count}',
          action: 'Deposit for glass bottle',
          depositRupees: item.totalDepositRupees,
        ),
      );
    }

    items.clear();
    dismissAddedToCartBar();
    notifyListeners();
  }

  void requestBottleReturn(String orderId) {
    bottleReturnRequestedOrderIds.add(orderId);
    notifyListeners();
  }

  bool isBottleReturnRequested(String orderId) =>
      bottleReturnRequestedOrderIds.contains(orderId);

  void cancelOrder(String orderId) {
    final order = trackedOrders[orderId];
    if (order == null || !order.canCancel) return;

    final cancelId = AppIdGenerator.generate5CharId();
    final cancelled = order.copyWith(
      status: OrderTrackStatus.cancelled,
      cancellationId: cancelId,
    );
    trackedOrders[orderId] = cancelled;
    if (activeTrackedOrder?.orderId == orderId) {
      activeTrackedOrder = cancelled;
    }

    final historyIndex = completedOrders.indexWhere((e) => e.id == orderId);
    if (historyIndex >= 0) {
      final entry = completedOrders[historyIndex];
      completedOrders[historyIndex] = OrderHistoryEntry(
        id: entry.id,
        orderedAt: entry.orderedAt,
        totalRupees: entry.totalRupees,
        summaryLines: entry.summaryLines,
        products: entry.products,
        footerLines: entry.footerLines,
        isCancelled: true,
        cancellationId: cancelId,
      );
    }

    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }
}
