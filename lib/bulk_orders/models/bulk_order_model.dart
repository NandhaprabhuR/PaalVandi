import 'package:equatable/equatable.dart';

/// Bulk order model for Hotel/Event/Business orders
class BulkOrderModel extends Equatable {
  final String id;
  final String businessName;
  final String contactPerson;
  final String phone;
  final String address;
  final String orderType; // 'Hotel' | 'Event' | 'Business'
  final double milkQuantity; // in liters
  final String deliveryTime;
  final String specialNotes;
  final String paymentStatus; // 'Paid' | 'Pay At Delivery' | 'Pending' | 'Paid Fully' | 'Partially Paid'
  final double totalAmount;
  final bool isDelivered;
  final String productDetails;
  final double collectedAmount;
  final DateTime? deliveryDate;

  const BulkOrderModel({
    required this.id,
    required this.businessName,
    required this.contactPerson,
    required this.phone,
    required this.address,
    required this.orderType,
    required this.milkQuantity,
    required this.deliveryTime,
    this.specialNotes = '',
    this.paymentStatus = 'Pending',
    this.totalAmount = 0,
    this.isDelivered = false,
    this.productDetails = 'Cow Milk',
    this.collectedAmount = 0,
    this.deliveryDate,
  });

  BulkOrderModel copyWith({
    bool? isDelivered,
    String? paymentStatus,
    double? collectedAmount,
    DateTime? deliveryDate,
    String? productDetails,
  }) {
    return BulkOrderModel(
      id: id,
      businessName: businessName,
      contactPerson: contactPerson,
      phone: phone,
      address: address,
      orderType: orderType,
      milkQuantity: milkQuantity,
      deliveryTime: deliveryTime,
      specialNotes: specialNotes,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalAmount: totalAmount,
      isDelivered: isDelivered ?? this.isDelivered,
      productDetails: productDetails ?? this.productDetails,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }

  @override
  List<Object?> get props => [
        id, businessName, contactPerson, phone, address, orderType,
        milkQuantity, deliveryTime, specialNotes, paymentStatus,
        totalAmount, isDelivered, productDetails, collectedAmount,
        deliveryDate,
      ];
}
