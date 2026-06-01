class HomeProductItem {
  final String quantity;
  final String price;
  final int priceRupees;

  const HomeProductItem({
    required this.quantity,
    required this.price,
    required this.priceRupees,
  });
}

class HomeProductSectionData {
  final String heading;
  final String productName;
  final List<HomeProductItem> products;
  final bool showDepositBadge;
  final bool showRefillBadge;

  const HomeProductSectionData({
    required this.heading,
    required this.productName,
    required this.products,
    this.showDepositBadge = true,
    this.showRefillBadge = true,
  });
}

class HomePromoCardData {
  final String emoji;
  final String title;
  final List<String> lines;

  const HomePromoCardData({
    required this.emoji,
    required this.title,
    required this.lines,
  });
}

class HomeCatalogData {
  static const String deliveryArea = 'Coimbatore';

  static const List<HomePromoCardData> promoCards = [
    HomePromoCardData(
      emoji: '🥛',
      title: 'Pure Fresh Milk',
      lines: ['No water added', 'Glass bottle delivery'],
    ),
    HomePromoCardData(
      emoji: '🚚',
      title: 'Fast Delivery',
      lines: ['Delivery within 20 minutes'],
    ),
    HomePromoCardData(
      emoji: '⏰',
      title: 'Delivery Timing',
      lines: ['Morning 5:00 AM to Night 9:00 PM'],
    ),
    HomePromoCardData(
      emoji: '🏨',
      title: 'Bulk Orders Available',
      lines: ['Hotels and Events supported'],
    ),
  ];

  static List<HomeProductItem> variantsForProduct(String productName) {
    for (final section in productSections) {
      if (section.productName == productName) {
        return section.products;
      }
    }
    return const [];
  }

  static const List<HomeProductSectionData> productSections = [
    HomeProductSectionData(
      heading: 'Milk',
      productName: 'Fresh Cow Milk',
      showDepositBadge: true,
      showRefillBadge: true,
      products: [
        HomeProductItem(quantity: '100ml', price: '₹12', priceRupees: 12),
        HomeProductItem(quantity: '250ml', price: '₹28', priceRupees: 28),
        HomeProductItem(quantity: '500ml', price: '₹35', priceRupees: 35),
        HomeProductItem(quantity: '750ml', price: '₹48', priceRupees: 48),
        HomeProductItem(quantity: '1L', price: '₹60', priceRupees: 60),
        HomeProductItem(quantity: '1.5L', price: '₹85', priceRupees: 85),
        HomeProductItem(quantity: '2L', price: '₹110', priceRupees: 110),
      ],
    ),
    HomeProductSectionData(
      heading: 'Curd',
      productName: 'Fresh Curd',
      showDepositBadge: true,
      showRefillBadge: true,
      products: [
        HomeProductItem(quantity: '200g', price: '₹25', priceRupees: 25),
        HomeProductItem(quantity: '500g', price: '₹45', priceRupees: 45),
        HomeProductItem(quantity: '1kg', price: '₹80', priceRupees: 80),
      ],
    ),
    HomeProductSectionData(
      heading: 'Buttermilk (Moor)',
      productName: 'Fresh Buttermilk',
      showDepositBadge: false,
      showRefillBadge: true,
      products: [
        HomeProductItem(quantity: '250ml', price: '₹18', priceRupees: 18),
        HomeProductItem(quantity: '500ml', price: '₹30', priceRupees: 30),
        HomeProductItem(quantity: '1L', price: '₹50', priceRupees: 50),
      ],
    ),
  ];
}
