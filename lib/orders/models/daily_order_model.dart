import 'package:equatable/equatable.dart';

/// Product item inside a daily order
class OrderProduct extends Equatable {
  final String name;
  final int quantity;
  final String unit; // '1L', '500ml', etc.

  const OrderProduct({
    required this.name,
    required this.quantity,
    this.unit = '1L',
  });

  @override
  List<Object?> get props => [name, quantity, unit];
}

/// Daily instant customer order model
class DailyOrderModel extends Equatable {
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String address;
  final List<OrderProduct> products;
  final double milkQty;
  final double curdQty;
  final double buttermilkQty;
  final String deliveryType; // 'Deposit Bottle' | 'Bring Own Container'
  final String paymentStatus; // 'Paid' | 'Pay At Delivery' | 'Pending'
  final String paymentMethod; // 'UPI' | 'Cash on Delivery' | 'Wallet'
  final double bottleDepositAmount; // Deposit amount if 'Deposit Bottle'
  final double totalAmount;
  final String status; // 'Assigned' | 'Accepted' | 'Delivered' | 'Cancelled'
  final DateTime orderTime;

  const DailyOrderModel({
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.products,
    this.milkQty = 0,
    this.curdQty = 0,
    this.buttermilkQty = 0,
    this.deliveryType = 'Deposit Bottle',
    this.paymentStatus = 'Pending',
    this.paymentMethod = 'UPI',
    this.bottleDepositAmount = 0,
    this.totalAmount = 0,
    this.status = 'Assigned',
    required this.orderTime,
  });

  DailyOrderModel copyWith({
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    double? bottleDepositAmount,
  }) {
    return DailyOrderModel(
      orderId: orderId,
      customerName: customerName,
      customerPhone: customerPhone,
      address: address,
      products: products,
      milkQty: milkQty,
      curdQty: curdQty,
      buttermilkQty: buttermilkQty,
      deliveryType: deliveryType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bottleDepositAmount: bottleDepositAmount ?? this.bottleDepositAmount,
      totalAmount: totalAmount,
      status: status ?? this.status,
      orderTime: orderTime,
    );
  }

  @override
  List<Object?> get props => [
        orderId, customerName, customerPhone, address, products,
        milkQty, curdQty, buttermilkQty, deliveryType, paymentStatus,
        paymentMethod, bottleDepositAmount, totalAmount, status, orderTime,
      ];
}
