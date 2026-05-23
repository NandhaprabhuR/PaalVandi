import 'cart_models.dart';
import '../../payment/models/payment_model.dart';

/// One product row in order / track UI (avoids duplicate deposit lines).
class OrderProductDisplay {
  final String titleLine;
  final String? detailLine;

  const OrderProductDisplay({
    required this.titleLine,
    this.detailLine,
  });
}

List<OrderProductDisplay> orderProductsFromCartItems(List<CartLineItem> items) {
  return items
      .map(
        (item) => OrderProductDisplay(
          titleLine: '${item.productName} ${item.quantity} ×${item.count}',
          detailLine: item.hasDeposit
              ? 'Deposit for glass bottle ₹${item.totalDepositRupees}'
              : (item.deliveryMethod == DeliveryMethod.bringMyContainer
                  ? 'Own container'
                  : null),
        ),
      )
      .toList();
}

List<String> orderFooterLines({
  required int deliveryChargeRupees,
  required PaalvandiPaymentMethod paymentMethod,
  UpiAppOption? upiApp,
}) {
  final lines = <String>[];
  if (deliveryChargeRupees > 0) {
    lines.add('Delivery ₹$deliveryChargeRupees');
  }
  lines.add(switch (paymentMethod) {
    PaalvandiPaymentMethod.payNowUpi => 'Paid via ${upiApp?.label ?? 'UPI'}',
    PaalvandiPaymentMethod.payAtDelivery => 'Pay at delivery',
    PaalvandiPaymentMethod.none => 'Payment pending',
  });
  return lines;
}

bool _isOrderFooterLine(String line) {
  return line == 'Order cancelled' ||
      line == 'Pay at delivery' ||
      line == 'Payment pending' ||
      line.startsWith('Delivery ₹') ||
      line.startsWith('Paid via');
}

bool _looksLikeProductLine(String line) {
  return line.contains('×') ||
      line.startsWith('Fresh ') ||
      line.startsWith('Buttermilk');
}

/// Fallback when only legacy [summaryLines] exist (older in-memory orders).
List<OrderProductDisplay> productsFromLegacySummary(List<String> lines) {
  final products = <OrderProductDisplay>[];

  void attachDetailToLast(String detail) {
    if (products.isEmpty) return;
    final last = products.last;
    products[products.length - 1] = OrderProductDisplay(
      titleLine: last.titleLine,
      detailLine: detail,
    );
  }

  for (final line in lines) {
    if (_isOrderFooterLine(line)) continue;

    if (line == 'Deposit for glass bottle') continue;

    if (line.startsWith('Deposit for glass bottle ₹') || line == 'Own container') {
      attachDetailToLast(line);
      continue;
    }

    if (_looksLikeProductLine(line)) {
      products.add(OrderProductDisplay(titleLine: line));
    }
  }
  return products;
}

bool orderHasGlassDeposit(List<OrderProductDisplay> products) {
  return products.any(
    (p) => p.detailLine?.contains('Deposit for glass bottle') == true,
  );
}

int glassDepositTotalFromProducts(List<OrderProductDisplay> products) {
  var total = 0;
  for (final p in products) {
    final line = p.detailLine;
    if (line == null || !line.contains('Deposit for glass bottle')) continue;
    final match = RegExp(r'₹(\d+)').firstMatch(line);
    if (match != null) total += int.parse(match.group(1)!);
  }
  return total;
}

List<String> footerLinesFromLegacySummary(List<String> lines) {
  return lines
      .where(
        (line) =>
            line.startsWith('Delivery ₹') ||
            line.startsWith('Paid via') ||
            line == 'Pay at delivery',
      )
      .toList();
}
