import 'package:equatable/equatable.dart';

/// Delivery Partner profile model with admin approval status.
class PartnerModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String vehicleNumber;
  final String photo; // emoji or asset path
  final bool isApproved;
  final String zone; // delivery zone

  const PartnerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleNumber,
    this.photo = '',
    this.isApproved = false,
    this.zone = 'Coimbatore',
  });

  PartnerModel copyWith({
    String? name,
    String? photo,
    String? vehicleNumber,
    bool? isApproved,
  }) {
    return PartnerModel(
      id: id,
      name: name ?? this.name,
      phone: phone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      photo: photo ?? this.photo,
      isApproved: isApproved ?? this.isApproved,
      zone: zone,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, vehicleNumber, photo, isApproved, zone];
}
