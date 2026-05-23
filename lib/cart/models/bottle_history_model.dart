class BottleHistoryEntry {
  final String orderId;
  final DateTime date;
  final String productName;
  final String quantity;
  final String action; // Delivered, Returned, Deposit paid
  final int depositRupees;
  final int? refundRupees;

  const BottleHistoryEntry({
    required this.orderId,
    required this.date,
    required this.productName,
    required this.quantity,
    required this.action,
    required this.depositRupees,
    this.refundRupees,
  });
}

class BottleHistoryData {
  static List<BottleHistoryEntry> sampleHistory() {
    final now = DateTime.now();
    return [
      BottleHistoryEntry(
        orderId: 'PV-2401',
        date: now.subtract(const Duration(hours: 5)),
        productName: 'Fresh Curd',
        quantity: '500g',
        action: 'Deposit paid',
        depositRupees: 20,
      ),
      BottleHistoryEntry(
        orderId: 'PV-2398',
        date: now.subtract(const Duration(days: 2)),
        productName: 'Fresh Cow Milk',
        quantity: '1L',
        action: 'Bottle delivered',
        depositRupees: 20,
      ),
      BottleHistoryEntry(
        orderId: 'PV-2395',
        date: now.subtract(const Duration(days: 4)),
        productName: 'Fresh Cow Milk',
        quantity: '500ml',
        action: 'Bottle returned',
        depositRupees: 20,
        refundRupees: 20,
      ),
      BottleHistoryEntry(
        orderId: 'PV-2390',
        date: now.subtract(const Duration(days: 7)),
        productName: 'Fresh Curd',
        quantity: '1kg',
        action: 'Bottle delivered',
        depositRupees: 20,
      ),
    ];
  }
}
