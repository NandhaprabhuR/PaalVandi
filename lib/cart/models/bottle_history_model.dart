class BottleHistoryEntry {
  final String orderId;
  final DateTime date;
  final String productName;
  final String quantity;
  final String action; // Delivered, Returned, Deposit paid
  final int depositRupees;
  final int? refundRupees;
  final String? walletId;

  const BottleHistoryEntry({
    required this.orderId,
    required this.date,
    required this.productName,
    required this.quantity,
    required this.action,
    required this.depositRupees,
    this.refundRupees,
    this.walletId,
  });
}

class BottleHistoryData {
  static List<BottleHistoryEntry> sampleHistory() {
    final now = DateTime.now();
    return [
      BottleHistoryEntry(
        orderId: 'F8K2L',
        date: now.subtract(const Duration(hours: 5)),
        productName: 'Fresh Curd',
        quantity: '500g',
        action: 'Deposit paid',
        depositRupees: 20,
        walletId: 'W3M8P',
      ),
      BottleHistoryEntry(
        orderId: 'B4P9X',
        date: now.subtract(const Duration(days: 2)),
        productName: 'Fresh Cow Milk',
        quantity: '1L',
        action: 'Bottle delivered',
        depositRupees: 20,
        walletId: 'W9J4K',
      ),
      BottleHistoryEntry(
        orderId: 'H5T7N',
        date: now.subtract(const Duration(days: 4)),
        productName: 'Fresh Cow Milk',
        quantity: '500ml',
        action: 'Bottle returned',
        depositRupees: 20,
        refundRupees: 20,
        walletId: 'W2C7X',
      ),
      BottleHistoryEntry(
        orderId: 'M7Q3Y',
        date: now.subtract(const Duration(days: 7)),
        productName: 'Fresh Curd',
        quantity: '1kg',
        action: 'Bottle delivered',
        depositRupees: 20,
        walletId: 'W6L5V',
      ),
    ];
  }
}
