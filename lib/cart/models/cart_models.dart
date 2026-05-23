enum DeliveryMethod { depositBottle, bringMyContainer }

enum ContainerSizeOption { ml500, l1, l2, custom }

extension DeliveryMethodUi on DeliveryMethod {
  String get label => switch (this) {
        DeliveryMethod.depositBottle => 'Deposit for glass bottle',
        DeliveryMethod.bringMyContainer => 'Own container',
      };

  String get billLine => switch (this) {
        DeliveryMethod.depositBottle => 'Deposit for glass bottle',
        DeliveryMethod.bringMyContainer => 'Own container (no deposit)',
      };
}

class CartLineItem {
  static const int glassBottleDepositRupees = 20;

  final String productName;
  final String quantity;
  final int milkPriceRupees;
  final DeliveryMethod deliveryMethod;
  final int? bottleDepositRupees;
  final ContainerSizeOption? containerSize;
  final String? customQuantity;
  final String? deliveryNotes;
  final int count;

  const CartLineItem({
    required this.productName,
    required this.quantity,
    required this.milkPriceRupees,
    required this.deliveryMethod,
    this.bottleDepositRupees,
    this.containerSize,
    this.customQuantity,
    this.deliveryNotes,
    this.count = 1,
  });

  int get depositPerUnitRupees => hasDeposit
      ? (bottleDepositRupees ?? glassBottleDepositRupees)
      : 0;

  int get unitTotalRupees => milkPriceRupees + depositPerUnitRupees;

  int get lineTotalRupees => unitTotalRupees * count;

  int get totalDepositRupees => depositPerUnitRupees * count;

  int get totalRupees => unitTotalRupees;

  CartLineItem copyWith({
    int? count,
    String? quantity,
    int? milkPriceRupees,
    DeliveryMethod? deliveryMethod,
    int? bottleDepositRupees,
    bool clearBottleDeposit = false,
  }) {
    return CartLineItem(
      productName: productName,
      quantity: quantity ?? this.quantity,
      milkPriceRupees: milkPriceRupees ?? this.milkPriceRupees,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      bottleDepositRupees: clearBottleDeposit
          ? null
          : (bottleDepositRupees ?? this.bottleDepositRupees),
      containerSize: containerSize,
      customQuantity: customQuantity,
      deliveryNotes: deliveryNotes,
      count: count ?? this.count,
    );
  }

  bool get hasDeposit => deliveryMethod == DeliveryMethod.depositBottle;

  String get containerSizeLabel {
    switch (containerSize) {
      case ContainerSizeOption.ml500:
        return '500ml';
      case ContainerSizeOption.l1:
        return '1L';
      case ContainerSizeOption.l2:
        return '2L';
      case ContainerSizeOption.custom:
        return customQuantity?.isNotEmpty == true
            ? customQuantity!
            : 'Custom';
      case null:
        return '';
    }
  }
}
