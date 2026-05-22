import 'package:equatable/equatable.dart';

class CustomersOtpModel extends Equatable {
  final String otpCode;

  const CustomersOtpModel({
    this.otpCode = '',
  });

  CustomersOtpModel copyWith({
    String? otpCode,
  }) {
    return CustomersOtpModel(
      otpCode: otpCode ?? this.otpCode,
    );
  }

  @override
  List<Object> get props => [otpCode];
}
