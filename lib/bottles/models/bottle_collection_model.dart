import 'package:equatable/equatable.dart';

/// Bottle collection model for pending customer bottle returns
class BottleCollectionModel extends Equatable {
  final String id;
  final String customerName;
  final String address;
  final String phone;
  final int pendingBottles;
  final double depositValue;
  final bool isCollected;
  final DateTime? collectionDate;
  final DateTime? requestDate;

  const BottleCollectionModel({
    required this.id,
    required this.customerName,
    required this.address,
    required this.phone,
    required this.pendingBottles,
    required this.depositValue,
    this.isCollected = false,
    this.collectionDate,
    this.requestDate,
  });

  BottleCollectionModel copyWith({bool? isCollected, DateTime? collectionDate, DateTime? requestDate}) {
    return BottleCollectionModel(
      id: id,
      customerName: customerName,
      address: address,
      phone: phone,
      pendingBottles: pendingBottles,
      depositValue: depositValue,
      isCollected: isCollected ?? this.isCollected,
      collectionDate: collectionDate ?? this.collectionDate,
      requestDate: requestDate ?? this.requestDate,
    );
  }

  @override
  List<Object?> get props => [
        id, customerName, address, phone,
        pendingBottles, depositValue, isCollected, collectionDate, requestDate
      ];
}
