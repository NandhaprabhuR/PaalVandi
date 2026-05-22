import 'package:equatable/equatable.dart';

class CustomersLoginModel extends Equatable {
  final String phoneNumber;

  const CustomersLoginModel({
    this.phoneNumber = '',
  });

  CustomersLoginModel copyWith({
    String? phoneNumber,
  }) {
    return CustomersLoginModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  List<Object> get props => [phoneNumber];
}
