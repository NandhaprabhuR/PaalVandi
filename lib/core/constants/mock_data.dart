import '../../auth/models/partner_model.dart';
import '../../orders/models/daily_order_model.dart';
import '../../subscriptions/models/delivery_ledger_entry.dart';
import '../../subscriptions/models/subscription_billing_model.dart';
import '../../subscriptions/models/subscription_delivery_model.dart';
import '../../bulk_orders/models/bulk_order_model.dart';
import '../../bottles/models/bottle_collection_model.dart';

/// Centralized mock data for the entire delivery partner app.
/// Replace with Supabase queries when backend is connected.
class MockData {
  // ─── Approved Partner Numbers ──────────────────────────────
  static const List<String> approvedPhones = [
    '9361051718',
    '9876543210',
    '8870123456',
    '9443210987',
  ];

  // ─── Partner Profile ───────────────────────────────────────
  static const PartnerModel partnerProfile = PartnerModel(
    id: 'PV-DP-4820',
    name: 'Ravi Kumar',
    phone: '9361051718',
    vehicleNumber: 'TN-37-BY-8832',
    photo: '',
    isApproved: true,
    zone: 'Coimbatore',
  );

  // ─── Daily Orders ─────────────────────────────────────────
  static List<DailyOrderModel> dailyOrders = [
    DailyOrderModel(
      orderId: 'PV-7842',
      customerName: 'Nandha Prabhu',
      customerPhone: '9361051718',
      address: '14, Cross Cut Road, Gandhipuram, Coimbatore',
      products: const [
        OrderProduct(name: 'Fresh Cow Milk', quantity: 2, unit: '1L'),
        OrderProduct(name: 'Premium Buttermilk', quantity: 1, unit: '500ml'),
      ],
      milkQty: 2,
      curdQty: 0,
      buttermilkQty: 0.5,
      deliveryType: 'Deposit Bottle',
      paymentStatus: 'Pay At Delivery',
      paymentMethod: 'Cash on Delivery',
      bottleDepositAmount: 60.00,
      totalAmount: 180.00,
      status: 'Assigned',
      orderTime: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    DailyOrderModel(
      orderId: 'PV-7843',
      customerName: 'Anjali Sharma',
      customerPhone: '9443210987',
      address: 'SF-4, Green Meadows Apartments, Saravanampatti',
      products: const [
        OrderProduct(name: 'Fresh Cow Milk', quantity: 1, unit: '1L'),
        OrderProduct(name: 'Fresh Cow Curd', quantity: 2, unit: '500ml'),
      ],
      milkQty: 1,
      curdQty: 1,
      buttermilkQty: 0,
      deliveryType: 'Bring Own Container',
      paymentStatus: 'Paid',
      paymentMethod: 'UPI',
      bottleDepositAmount: 0.00,
      totalAmount: 150.00,
      status: 'Assigned',
      orderTime: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
    DailyOrderModel(
      orderId: 'PV-7844',
      customerName: 'Sridhar Subramanian',
      customerPhone: '8870123456',
      address: '102, Shanthi Colony, Peelamedu, Coimbatore',
      products: const [
        OrderProduct(name: 'Premium Cow Milk', quantity: 3, unit: '1L'),
      ],
      milkQty: 3,
      curdQty: 0,
      buttermilkQty: 0,
      deliveryType: 'Deposit Bottle',
      paymentStatus: 'Pending',
      paymentMethod: 'PaalVandi Wallet',
      bottleDepositAmount: 90.00,
      totalAmount: 270.00,
      status: 'Assigned', // Let's set it to Assigned so the delivery partner can Accept/Cancel it!
      orderTime: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    DailyOrderModel(
      orderId: 'PV-7845',
      customerName: 'Meena Lakshmi',
      customerPhone: '9087654321',
      address: '45, Nehru Nagar, RS Puram, Coimbatore',
      products: const [
        OrderProduct(name: 'Fresh Cow Milk', quantity: 1, unit: '500ml'),
        OrderProduct(name: 'Premium Buttermilk', quantity: 2, unit: '500ml'),
        OrderProduct(name: 'Fresh Cow Curd', quantity: 1, unit: '500ml'),
      ],
      milkQty: 0.5,
      curdQty: 0.5,
      buttermilkQty: 1,
      deliveryType: 'Deposit Bottle',
      paymentStatus: 'Paid',
      paymentMethod: 'UPI',
      bottleDepositAmount: 30.00,
      totalAmount: 195.00,
      status: 'Assigned',
      orderTime: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  // ─── Subscription Billing Helper ───────────────────────────
  static Map<String, double> getBillingInfoForSub(String id, String rawQty, String timing, String subType) {
    double qty = 1.0;
    final match = RegExp(r'([\d.]+)\s*(L|ml)').firstMatch(rawQty);
    if (match != null) {
      qty = double.tryParse(match.group(1) ?? '1.0') ?? 1.0;
      if (match.group(2)?.toLowerCase() == 'ml') {
        qty /= 1000.0;
      }
    }

    double rate = 60.0;
    if (subType == 'Business') {
      rate = 55.0;
    }

    double advance = 100.0;
    double deliveredQty = 0.0;

    if (id == 'SUB-VAD-2') {
      advance = 80.0;
      // Mon=1, Tue=2, Wed=1. June 1, 2, 3 are Mon, Tue, Wed.
      deliveredQty = 4.0;
    } else if (id == 'SUB-SAI-5') {
      qty = 50.0;
      rate = 55.0;
      advance = 500.0;
      deliveredQty = 3.0 * qty;
    } else if (id == 'SUB-VAD-1') {
      qty = 1.0;
      rate = 60.0;
      advance = 100.0;
      deliveredQty = 3.0 * qty;
    } else if (id == 'SUB-VAD-3') {
      qty = 20.0;
      rate = 55.0;
      advance = 2000.0;
      deliveredQty = 3.0 * qty;
    } else {
      deliveredQty = 3.0 * qty;
    }

    double bill = deliveredQty * rate;
    double balance = bill - advance;
    if (balance < 0) balance = 0.0;

    return {
      'paid': advance,
      'balance': balance,
    };
  }

  // ─── Subscription Deliveries ──────────────────────────────
  static List<SubscriptionDeliveryModel> _generateSubscriptionDeliveries() {
    final list = <SubscriptionDeliveryModel>[];
    
    // 1. Vadavalli Route (12 customers, 15L Milk, Morning)
    // 10 Active, 1 Paused, 1 Vacation
    final vadavalliNames = [
      'Karthik Rajan', 'Aravind Swamy', 'Bala Murugan', 'Chitra Devi', 
      'Dinesh Kumar', 'Elango V', 'Fathima Beevi', 'Ganesh Prasad', 
      'Hari Krishnan', 'Indira Priyadarshini', 'Jaya Prada', 'Kavin Kumar'
    ];
    final vadavalliQtys = [
      '1.5L Milk', '1L Milk', '2L Milk', '1L Milk', '1L Milk', 
      '2L Milk', '1.5L Milk', '1L Milk', '3L Milk', '1L Milk',
      '500ml Milk', '1L Milk'
    ];
    for (int i = 0; i < 12; i++) {
      String status = 'Active';
      if (i == 10) status = 'Paused';
      if (i == 11) status = 'Vacation Mode';
      
      final subType = i % 3 == 0 ? 'Family' : (i % 3 == 1 ? 'Smart' : 'Business');
      final billingInfo = getBillingInfoForSub(
        'SUB-VAD-${i + 1}',
        vadavalliQtys[i],
        'Morning',
        subType,
      );

      list.add(SubscriptionDeliveryModel(
        id: 'SUB-VAD-${i + 1}',
        customerName: vadavalliNames[i],
        phone: '98765${10000 + i}',
        address: '${10 + i * 4}, Bharathi Street, Vadavalli',
        subscriptionType: subType,
        quantity: vadavalliQtys[i],
        timing: 'Morning',
        routeName: 'Vadavalli Route',
        status: status,
        pendingBottles: (i % 4 == 0) ? (i + 2) : 0,
        balanceAmount: billingInfo['balance']!,
        paidAmount: billingInfo['paid']!,
      ));
    }

    // 2. Saibaba Colony Route (8 customers, 10L Milk, Morning)
    // 7 Active, 1 Paused
    final saibabaNames = [
      'Manish S', 'Naveen Kumar', 'Omprakash R', 'Preethi V', 
      'Qadir Khan', 'Ramya Krishnan', 'Suresh Raina', 'Thangavelu P'
    ];
    final saibabaQtys = [
      '1L Milk', '2L Milk', '1L Milk', '1.5L Milk', '1.5L Milk', 
      '2L Milk', '1L Milk', '500ml Milk'
    ];
    for (int i = 0; i < 8; i++) {
      String status = 'Active';
      if (i == 7) status = 'Paused';
      
      final subType = i % 2 == 0 ? 'Smart' : 'Family';
      final billingInfo = getBillingInfoForSub(
        'SUB-SAI-${i + 1}',
        saibabaQtys[i],
        'Morning',
        subType,
      );

      list.add(SubscriptionDeliveryModel(
        id: 'SUB-SAI-${i + 1}',
        customerName: saibabaNames[i],
        phone: '94430${20000 + i}',
        address: '${5 + i * 3}, Alagesan Road, Saibaba Colony',
        subscriptionType: subType,
        quantity: saibabaQtys[i],
        timing: 'Morning',
        routeName: 'Saibaba Colony Route',
        status: status,
        pendingBottles: (i % 3 == 1) ? (i + 1) : 0,
        balanceAmount: billingInfo['balance']!,
        paidAmount: billingInfo['paid']!,
      ));
    }

    // 3. RS Puram Route (15 customers, 20L Milk, Evening)
    // 13 Active, 1 Paused, 1 Vacation
    final rsPuramNames = [
      'Arun Prasad', 'Baskar C', 'Chandran M', 'Devi Priya', 
      'Ezhil Raja', 'Farook S', 'Gita Govind', 'Hemamalini S', 
      'Ilaiyaraaja M', 'Jeeva K', 'Kannan V', 'Loganathan T',
      'Mani Kandan', 'Nalini G', 'Oviya A'
    ];
    final rsPuramQtys = [
      '1L Milk', '1L Milk', '2L Milk', '1.5L Milk', '1.5L Milk', 
      '2L Milk', '1L Milk', '2L Milk', '1.5L Milk', '1L Milk', 
      '2L Milk', '1.5L Milk', '1L Milk', '500ml Milk', '1.5L Milk'
    ];
    for (int i = 0; i < 15; i++) {
      String status = 'Active';
      if (i == 13) status = 'Paused';
      if (i == 14) status = 'Vacation Mode';
      
      final subType = i % 4 == 0 ? 'Business' : (i % 2 == 0 ? 'Family' : 'Smart');
      final billingInfo = getBillingInfoForSub(
        'SUB-RSP-${i + 1}',
        rsPuramQtys[i],
        'Evening',
        subType,
      );

      list.add(SubscriptionDeliveryModel(
        id: 'SUB-RSP-${i + 1}',
        customerName: rsPuramNames[i],
        phone: '80123${30000 + i}',
        address: '${20 + i * 5}, D.B. Road, RS Puram',
        subscriptionType: subType,
        quantity: rsPuramQtys[i],
        timing: 'Evening',
        routeName: 'RS Puram Route',
        status: status,
        pendingBottles: (i % 5 == 2) ? (i + 1) : 0,
        balanceAmount: billingInfo['balance']!,
        paidAmount: billingInfo['paid']!,
      ));
    }

    return list;
  }

  static final List<BulkOrderModel> bulkOrders = [
    BulkOrderModel(
      id: 'BLK-101',
      businessName: 'Hotel Temple Towers',
      contactPerson: 'Murugan S',
      phone: '9876501234',
      address: '45, Avinashi Road, Coimbatore',
      orderType: 'Hotel',
      milkQuantity: 20,
      deliveryTime: '5:30 AM',
      specialNotes: 'Use service entrance. Contact security first.',
      paymentStatus: 'Paid',
      totalAmount: 1800.00,
      productDetails: 'Cow Milk (20L)',
    ),
    BulkOrderModel(
      id: 'BLK-102',
      businessName: 'Grand Kalyana Mandapam',
      contactPerson: 'Senthil Kumar',
      phone: '9443567890',
      address: '12, Mettupalayam Road, Coimbatore',
      orderType: 'Event',
      milkQuantity: 50,
      deliveryTime: '4:00 AM',
      specialNotes: 'Wedding function. Extra fresh curd needed too.',
      paymentStatus: 'Pay At Delivery',
      totalAmount: 4500.00,
      productDetails: 'Cow Milk (35L) + Buffalo Milk (15L)',
    ),
    BulkOrderModel(
      id: 'BLK-103',
      businessName: 'TechPark Cafeteria',
      contactPerson: 'Anitha R',
      phone: '8870567890',
      address: 'KGISL Tech Park, Saravanampatti',
      orderType: 'Business',
      milkQuantity: 15,
      deliveryTime: '7:00 AM',
      specialNotes: 'Gate pass required. Call before arriving.',
      paymentStatus: 'Paid',
      totalAmount: 1350.00,
      productDetails: 'Cow Milk (10L) + Curd (5kg)',
    ),
    BulkOrderModel(
      id: 'BLK-901',
      businessName: 'Ananda Bhavan Hotel',
      contactPerson: 'Ramanathan P',
      phone: '9442123456',
      address: '102, DB Road, RS Puram, Coimbatore',
      orderType: 'Hotel',
      milkQuantity: 30,
      deliveryTime: '5:00 AM',
      paymentStatus: 'Paid Fully',
      totalAmount: 2700.00,
      isDelivered: true,
      productDetails: 'Cow Milk (30L)',
      collectedAmount: 2700.00,
      deliveryDate: DateTime(2026, 6, 2),
    ),
    BulkOrderModel(
      id: 'BLK-902',
      businessName: 'TechPark Cafeteria',
      contactPerson: 'Anitha R',
      phone: '8870567890',
      address: 'KGISL Tech Park, Saravanampatti',
      orderType: 'Business',
      milkQuantity: 15,
      deliveryTime: '7:00 AM',
      paymentStatus: 'Partially Paid',
      totalAmount: 1350.00,
      isDelivered: true,
      productDetails: 'Cow Milk (10L) + Curd (5kg)',
      collectedAmount: 800.00,
      deliveryDate: DateTime(2026, 6, 1),
    ),
    BulkOrderModel(
      id: 'BLK-903',
      businessName: 'Royal Wedding Hall',
      contactPerson: 'Vignesh K',
      phone: '9843012345',
      address: 'Trichy Road, Singanallur, Coimbatore',
      orderType: 'Event',
      milkQuantity: 80,
      deliveryTime: '3:30 AM',
      paymentStatus: 'Paid Fully',
      totalAmount: 7200.00,
      isDelivered: true,
      productDetails: 'Cow Milk (50L) + Buffalo Milk (30L)',
      collectedAmount: 7200.00,
      deliveryDate: DateTime(2026, 5, 28),
    ),
    BulkOrderModel(
      id: 'BLK-904',
      businessName: 'Annapoorna Hotel',
      contactPerson: 'Srinivasan M',
      phone: '9789012345',
      address: 'People\'s Park Road, Coimbatore',
      orderType: 'Hotel',
      milkQuantity: 25,
      deliveryTime: '5:45 AM',
      paymentStatus: 'Partially Paid',
      totalAmount: 2250.00,
      isDelivered: true,
      productDetails: 'Buffalo Milk (25L)',
      collectedAmount: 1200.00,
      deliveryDate: DateTime(2026, 5, 20),
    ),
    BulkOrderModel(
      id: 'BLK-905',
      businessName: 'Nesta Cafe & Bakery',
      contactPerson: 'John Wesley',
      phone: '9003012345',
      address: 'Race Course Road, Coimbatore',
      orderType: 'Business',
      milkQuantity: 10,
      deliveryTime: '8:00 AM',
      paymentStatus: 'Paid Fully',
      totalAmount: 900.00,
      isDelivered: true,
      productDetails: 'Organic Milk (10L)',
      collectedAmount: 900.00,
      deliveryDate: DateTime(2026, 5, 12),
    ),
    BulkOrderModel(
      id: 'BLK-906',
      businessName: 'Hotel Temple Towers',
      contactPerson: 'Murugan S',
      phone: '9876501234',
      address: '45, Avinashi Road, Coimbatore',
      orderType: 'Hotel',
      milkQuantity: 20,
      deliveryTime: '5:30 AM',
      paymentStatus: 'Paid Fully',
      totalAmount: 1800.00,
      isDelivered: true,
      productDetails: 'Cow Milk (20L)',
      collectedAmount: 1800.00,
      deliveryDate: DateTime(2026, 5, 5),
    ),
  ];

  // ─── Bottle Collections ───────────────────────────────────
  static final List<BottleCollectionModel> bottleCollections = [
    BottleCollectionModel(
      id: 'BTL-001',
      customerName: 'Nandha Prabhu',
      address: '14, Cross Cut Road, Gandhipuram',
      phone: '9361051718',
      pendingBottles: 4,
      depositValue: 120.00,
      requestDate: DateTime(2026, 6, 2, 8, 30),
    ),
    BottleCollectionModel(
      id: 'BTL-002',
      customerName: 'Rajesh Kumar',
      address: '102, Shanthi Colony, Peelamedu',
      phone: '8870123456',
      pendingBottles: 6,
      depositValue: 180.00,
      requestDate: DateTime(2026, 6, 3, 10, 15),
    ),
    BottleCollectionModel(
      id: 'BTL-003',
      customerName: 'Lakshmi Narayan',
      address: '12, Temple Road, Gandhipuram',
      phone: '9443012345',
      pendingBottles: 10,
      depositValue: 300.00,
      requestDate: DateTime(2026, 6, 3, 14, 45),
    ),
    BottleCollectionModel(
      id: 'BTL-004',
      customerName: 'Priya Venkatesh',
      address: '78, Anna Nagar, Singanallur',
      phone: '9876012345',
      pendingBottles: 2,
      depositValue: 60.00,
      requestDate: DateTime(2026, 6, 4, 9, 0),
    ),
    BottleCollectionModel(
      id: 'BTL-005',
      customerName: 'Meena Lakshmi',
      address: '45, Nehru Nagar, RS Puram',
      phone: '9087654321',
      pendingBottles: 3,
      depositValue: 90.00,
      requestDate: DateTime(2026, 6, 4, 11, 20),
    ),
  ];

  // ─── Subscription Billing & Accounting Data ───────────────
  static List<SubscriptionBillingModel> _generateSubscriptionBillingProfiles() {
    final profiles = <SubscriptionBillingModel>[];
    for (final sub in subscriptionDeliveries) {
      // Parse rate
      double rate = 60.0;
      if (sub.subscriptionType == 'Business') {
        rate = 55.0;
      }
      
      // Parse qty
      double qty = 1.0;
      final match = RegExp(r'([\d.]+)\s*(L|ml)').firstMatch(sub.quantity);
      if (match != null) {
        qty = double.tryParse(match.group(1) ?? '1.0') ?? 1.0;
        if (match.group(2)?.toLowerCase() == 'ml') {
          qty /= 1000.0;
        }
      }

      // Customize subscription types and weekday quantities
      String type = sub.subscriptionType;
      Map<int, double>? smartQtys;
      double advance = 100.0; // Changed default from 500.0 to 100.0
      
      // Make some subscriptions of type Smart, Business, Event, Family
      if (sub.id == 'SUB-VAD-2') {
        type = 'Smart';
        smartQtys = {
          1: 1.0, // Mon
          2: 2.0, // Tue
          3: 1.0, // Wed
          4: 0.5, // Thu
          5: 1.0, // Fri
          6: 2.0, // Sat
          7: 0.0, // Sun
        };
        advance = 80.0;
      } else if (sub.id == 'SUB-SAI-5') {
        type = 'Event';
        qty = 50.0; // 50L for event
        rate = 55.0;
        advance = 500.0;
      } else if (sub.id == 'SUB-VAD-1') {
        type = 'Family';
        qty = 1.0; // 1L daily
        rate = 60.0;
        advance = 100.0;
      } else if (sub.id == 'SUB-VAD-3') {
        type = 'Business';
        qty = 20.0; // 20L daily
        rate = 55.0;
        advance = 2000.0;
      }

      profiles.add(SubscriptionBillingModel(
        id: sub.id,
        customerName: sub.customerName,
        phone: sub.phone,
        subscriptionType: type,
        ratePerLiter: rate,
        morningQty: sub.timing == 'Morning' ? qty : 0.0,
        eveningQty: sub.timing == 'Evening' ? qty : (sub.timing == 'Morning' ? 0.0 : qty / 2),
        weekdayQuantities: smartQtys,
        advancePaid: advance,
        paymentStatus: 'Paid',
      ));
    }
    return profiles;
  }

  static List<DeliveryLedgerEntry> _generateLedgerEntries() {
    final entries = <DeliveryLedgerEntry>[];
    final profiles = _generateSubscriptionBillingProfiles();
    int entryIndex = 1;

    // Generate history for past months: January to December 2026
    final targetMonths = [
      _MonthYear(1, 2026),
      _MonthYear(2, 2026),
      _MonthYear(3, 2026),
      _MonthYear(4, 2026),
      _MonthYear(5, 2026),
      _MonthYear(6, 2026),
      _MonthYear(7, 2026),
      _MonthYear(8, 2026),
      _MonthYear(9, 2026),
      _MonthYear(10, 2026),
      _MonthYear(11, 2026),
      _MonthYear(12, 2026),
    ];

    for (final profile in profiles) {
      for (final my in targetMonths) {
        // Generate ledger entries for the entire month dynamically
        final daysCount = DateTime(my.year, my.month + 1, 0).day;

        for (int day = 1; day <= daysCount; day++) {
          final date = DateTime(my.year, my.month, day);
          String status = 'Delivered';

          // ─── SPECIFIC USER CASE MOCK MATCHING ───
          if (profile.id == 'SUB-VAD-1' && my.month == 2) {
            // Family Subscription Vacation Example:
            // 28 days total, Vacation = 5 Days (days 10, 11, 12, 13, 14)
            if (day >= 10 && day <= 14) {
              status = 'Vacation';
            }
          } else if (profile.id == 'SUB-VAD-3' && my.month == 3) {
            // Business Subscription Skip Example:
            // 31 days total, Skipped = 2 Days (days 15, 16)
            if (day == 15 || day == 16) {
              status = 'Customer Skip';
            }
          } else {
            // General deterministic statuses
            if (day % 15 == 0) {
              status = 'Customer Skip';
            } else if (day % 18 == 0) {
              status = 'Vacation';
            } else if (day % 22 == 0) {
              status = 'Paused';
            } else if (day % 27 == 0) {
              status = 'Failed Delivery';
            }
          }

          entries.add(DeliveryLedgerEntry(
            id: 'LED-${entryIndex++}',
            subscriptionId: profile.id,
            date: date,
            status: status,
            quantityMorning: profile.morningQty,
            quantityEvening: profile.eveningQty,
            ratePerLiter: profile.ratePerLiter,
          ));
        }
      }
    }
    return entries;
  }

  static final List<SubscriptionDeliveryModel> subscriptionDeliveries = _generateSubscriptionDeliveries();
  static final List<SubscriptionBillingModel> subscriptionBillingProfiles = _generateSubscriptionBillingProfiles();
  static final List<DeliveryLedgerEntry> deliveryLedger = _generateLedgerEntries();
}

class _MonthYear {
  final int month;
  final int year;
  const _MonthYear(this.month, this.year);
}
