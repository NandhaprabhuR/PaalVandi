import '../../payment/models/payment_model.dart';
import 'cart_models.dart';
import 'order_display_models.dart';

class OrderHistoryEntry {
  final String id;
  final DateTime orderedAt;
  final int totalRupees;
  final List<String> summaryLines;
  final List<OrderProductDisplay> products;
  final List<String> footerLines;
  final bool isCancelled;
  final String? cancellationId;

  const OrderHistoryEntry({
    required this.id,
    required this.orderedAt,
    required this.totalRupees,
    this.summaryLines = const [],
    this.products = const [],
    this.footerLines = const [],
    this.isCancelled = false,
    this.cancellationId,
  });

  List<OrderProductDisplay> get displayProducts => products.isNotEmpty
      ? products
      : productsFromLegacySummary(summaryLines);

  List<String> get displayFooters => footerLines.isNotEmpty
      ? footerLines
      : footerLinesFromLegacySummary(summaryLines);

  factory OrderHistoryEntry.fromCartItems({
    required String id,
    required DateTime orderedAt,
    required List<CartLineItem> items,
    required int deliveryChargeRupees,
    PaalvandiPaymentMethod paymentMethod = PaalvandiPaymentMethod.payAtDelivery,
    UpiAppOption? upiApp,
  }) {
    final productDisplays = orderProductsFromCartItems(items);
    final footers = orderFooterLines(
      deliveryChargeRupees: deliveryChargeRupees,
      paymentMethod: paymentMethod,
      upiApp: upiApp,
    );
    var subtotal = 0;
    for (final item in items) {
      subtotal += item.lineTotalRupees;
    }

    final legacyLines = <String>[
      for (final p in productDisplays) ...[
        p.titleLine,
        if (p.detailLine != null) p.detailLine!,
      ],
      ...footers,
    ];

    return OrderHistoryEntry(
      id: id,
      orderedAt: orderedAt,
      totalRupees: subtotal + deliveryChargeRupees,
      summaryLines: legacyLines,
      products: productDisplays,
      footerLines: footers,
    );
  }
}

class OrderHistoryData {
  static List<OrderHistoryEntry> sampleOrders() {
    final now = DateTime.now();
    return [
      OrderHistoryEntry(
        id: 'F8K2L',
        orderedAt: now.subtract(const Duration(days: 1)),
        totalRupees: 80,
        products: const [
          OrderProductDisplay(
            titleLine: 'Fresh Curd 500g ×1',
            detailLine: 'Deposit for glass bottle ₹20',
          ),
        ],
        footerLines: const [],
      ),
      OrderHistoryEntry(
        id: 'B4P9X',
        orderedAt: now.subtract(const Duration(days: 3)),
        totalRupees: 143,
        products: const [
          OrderProductDisplay(
            titleLine: 'Fresh Cow Milk 1L ×2',
            detailLine: 'Deposit for glass bottle ₹40',
          ),
        ],
        footerLines: const [],
      ),
      OrderHistoryEntry(
        id: 'M7Q3Y',
        orderedAt: now.subtract(const Duration(days: 7)),
        totalRupees: 65,
        products: const [
          OrderProductDisplay(
            titleLine: 'Fresh Buttermilk 1L ×1',
            detailLine: 'Own container',
          ),
        ],
        footerLines: const [],
      ),
    ];
  }
}
