class HomeProductItem {
  final String quantity;
  final String price;
  final int priceRupees;
  final double rating;
  final String totalOrders;
  final String stockStatus; // 'In Stock' | 'Low Stock' | 'Out of Stock'

  const HomeProductItem({
    required this.quantity,
    required this.price,
    required this.priceRupees,
    this.rating = 4.8,
    this.totalOrders = '1.2k orders',
    this.stockStatus = 'In Stock',
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
        HomeProductItem(quantity: '100ml', price: '₹12', priceRupees: 12, rating: 4.6, totalOrders: '950 orders', stockStatus: 'In Stock'),
        HomeProductItem(quantity: '250ml', price: '₹28', priceRupees: 28, rating: 4.7, totalOrders: '1.1k orders', stockStatus: 'In Stock'),
        HomeProductItem(quantity: '500ml', price: '₹35', priceRupees: 35, rating: 4.9, totalOrders: '2.5k orders', stockStatus: 'In Stock'),
        HomeProductItem(quantity: '750ml', price: '₹48', priceRupees: 48, rating: 4.8, totalOrders: '1.8k orders', stockStatus: 'Low Stock'),
        HomeProductItem(quantity: '1L', price: '₹60', priceRupees: 60, rating: 4.9, totalOrders: '3.2k orders', stockStatus: 'In Stock'),
        HomeProductItem(quantity: '1.5L', price: '₹85', priceRupees: 85, rating: 4.7, totalOrders: '850 orders', stockStatus: 'In Stock'),
        HomeProductItem(quantity: '2L', price: '₹110', priceRupees: 110, rating: 4.6, totalOrders: '420 orders', stockStatus: 'Out of Stock'),
      ],
    ),
    HomeProductSectionData(
      heading: 'Curd',
      productName: 'Fresh Curd',
      showDepositBadge: true,
      showRefillBadge: true,
      products: [
        HomeProductItem(quantity: '200g', price: '₹25', priceRupees: 25, rating: 4.8, totalOrders: '1.5k orders', stockStatus: 'In Stock'),
        HomeProductItem(quantity: '500g', price: '₹45', priceRupees: 45, rating: 4.9, totalOrders: '2.1k orders', stockStatus: 'In Stock'),
        HomeProductItem(quantity: '1kg', price: '₹80', priceRupees: 80, rating: 4.7, totalOrders: '750 orders', stockStatus: 'Low Stock'),
      ],
    ),
    HomeProductSectionData(
      heading: 'Buttermilk (Moor)',
      productName: 'Fresh Buttermilk',
      showDepositBadge: false,
      showRefillBadge: true,
      products: [
        HomeProductItem(quantity: '250ml', price: '₹18', priceRupees: 18, rating: 4.7, totalOrders: '1.3k orders', stockStatus: 'In Stock'),
        HomeProductItem(quantity: '500ml', price: '₹30', priceRupees: 30, rating: 4.8, totalOrders: '1.9k orders', stockStatus: 'In Stock'),
        HomeProductItem(quantity: '1L', price: '₹50', priceRupees: 50, rating: 4.6, totalOrders: '620 orders', stockStatus: 'Out of Stock'),
      ],
    ),
  ];
}
