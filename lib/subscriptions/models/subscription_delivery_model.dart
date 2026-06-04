import 'package:equatable/equatable.dart';

class SubscriptionDeliveryModel extends Equatable {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final String subscriptionType; // 'Family' | 'Business' | 'Smart'
  final String quantity;
  final String timing; // 'Morning' | 'Evening'
  final String bottleType; // 'Glass Bottle' | 'Plastic Pouch'
  final String status; // 'Active' | 'Paused' | 'Vacation Mode' | 'Cancelled'
  final bool isDelivered;
  final bool isSkipped;
  final String routeName;
  final int pendingBottles;
  final int bottlesCollected;
  final String? skipReason;
  final double balanceAmount;
  final double paidAmount;
  final String? deliveryTime;

  const SubscriptionDeliveryModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.subscriptionType,
    required this.quantity,
    required this.timing,
    this.bottleType = 'Glass Bottle',
    this.status = 'Active',
    this.isDelivered = false,
    this.isSkipped = false,
    this.routeName = 'General Route',
    this.pendingBottles = 0,
    this.bottlesCollected = 0,
    this.skipReason,
    this.balanceAmount = 0.0,
    this.paidAmount = 0.0,
    this.deliveryTime,
  });

  SubscriptionDeliveryModel copyWith({
    bool? isDelivered,
    bool? isSkipped,
    String? status,
    int? bottlesCollected,
    String? skipReason,
    String? routeName,
    int? pendingBottles,
    double? balanceAmount,
    double? paidAmount,
    String? deliveryTime,
  }) {
    return SubscriptionDeliveryModel(
      id: id,
      customerName: customerName,
      phone: phone,
      address: address,
      subscriptionType: subscriptionType,
      quantity: quantity,
      timing: timing,
      bottleType: bottleType,
      status: status ?? this.status,
      isDelivered: isDelivered ?? this.isDelivered,
      isSkipped: isSkipped ?? this.isSkipped,
      routeName: routeName ?? this.routeName,
      pendingBottles: pendingBottles ?? this.pendingBottles,
      bottlesCollected: bottlesCollected ?? this.bottlesCollected,
      skipReason: skipReason ?? this.skipReason,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }

  @override
  List<Object?> get props => [
        id, customerName, phone, address, subscriptionType,
        quantity, timing, bottleType, status, isDelivered, isSkipped,
        routeName, pendingBottles, bottlesCollected, skipReason,
        balanceAmount, paidAmount, deliveryTime,
      ];
}


