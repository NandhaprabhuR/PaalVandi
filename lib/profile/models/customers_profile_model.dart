import 'package:equatable/equatable.dart';

class CustomersProfileModel extends Equatable {
  final String name;
  final String houseNo;
  final String apartmentName;
  final String street;
  final String city;
  final String pincode;
  final String referralCode;
  final String fetchedLocation;
  final String deliveryPreference;

  const CustomersProfileModel({
    this.name = '',
    this.houseNo = '',
    this.apartmentName = '',
    this.street = '',
    this.city = 'Coimbatore',
    this.pincode = '',
    this.referralCode = '',
    this.fetchedLocation = '',
    this.deliveryPreference = 'Deliver Here (Primary)',
  });

  CustomersProfileModel copyWith({
    String? name,
    String? houseNo,
    String? apartmentName,
    String? street,
    String? city,
    String? pincode,
    String? referralCode,
    String? fetchedLocation,
    String? deliveryPreference,
  }) {
    return CustomersProfileModel(
      name: name ?? this.name,
      houseNo: houseNo ?? this.houseNo,
      apartmentName: apartmentName ?? this.apartmentName,
      street: street ?? this.street,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      referralCode: referralCode ?? this.referralCode,
      fetchedLocation: fetchedLocation ?? this.fetchedLocation,
      deliveryPreference: deliveryPreference ?? this.deliveryPreference,
    );
  }

  @override
  List<Object> get props => [
        name,
        houseNo,
        apartmentName,
        street,
        city,
        pincode,
        referralCode,
        fetchedLocation,
        deliveryPreference,
      ];
}
