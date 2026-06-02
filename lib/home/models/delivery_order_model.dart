import 'package:equatable/equatable.dart';

class DeliveryOrderModel extends Equatable {
  final String orderId; // 5-character alphanumeric ID
  final String customerName;
  final String customerPhone;
  final String address;
  final String landmark;
  final double totalAmount;
  final double advancePaid;
  final bool isCod;
  final List<DeliveryProductItem> items;
  final String deliveryStatus; // 'Assigned', 'Accepted', 'Arrived', 'Dispatched', 'Delivered'
  final String orderType;      // 'Order', 'Bulk Booking', 'Subscription'
  final String deliveryDate;
  final String timeSlot;

  const DeliveryOrderModel({
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.landmark,
    required this.totalAmount,
    required this.advancePaid,
    required this.isCod,
    required this.items,
    required this.deliveryStatus,
    required this.orderType,
    required this.deliveryDate,
    required this.timeSlot,
  });

  DeliveryOrderModel copyWith({
    String? deliveryStatus,
  }) {
    return DeliveryOrderModel(
      orderId: orderId,
      customerName: customerName,
      customerPhone: customerPhone,
      address: address,
      landmark: landmark,
      totalAmount: totalAmount,
      advancePaid: advancePaid,
      isCod: isCod,
      items: items,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      orderType: orderType,
      deliveryDate: deliveryDate,
      timeSlot: timeSlot,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        customerName,
        customerPhone,
        address,
        landmark,
        totalAmount,
        advancePaid,
        isCod,
        items,
        deliveryStatus,
        orderType,
        deliveryDate,
        timeSlot,
      ];
}

class DeliveryProductItem extends Equatable {
  final String productName;
  final int quantity;

  const DeliveryProductItem({
    required this.productName,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productName, quantity];
}
