class BottleWalletStats {
  static const int depositPerBottleRupees = 20;

  final int deliveredBottles;
  final int returnedBottles;

  const BottleWalletStats({
    this.deliveredBottles = 12,
    this.returnedBottles = 10,
  });

  /// Bottles still with the customer (delivered but not yet returned).
  int get pendingBottles =>
      (deliveredBottles - returnedBottles).clamp(0, deliveredBottles);

  /// Deposit refund owed for bottles already returned.
  int get refundBalanceRupees => returnedBottles * depositPerBottleRupees;
}
