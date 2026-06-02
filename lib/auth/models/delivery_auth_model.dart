import 'package:equatable/equatable.dart';

class DeliveryAuthModel extends Equatable {
  final String phoneNumber;
  final String otpCode;
  final bool isLoggedIn;

  const DeliveryAuthModel({
    this.phoneNumber = '',
    this.otpCode = '',
    this.isLoggedIn = false,
  });

  DeliveryAuthModel copyWith({
    String? phoneNumber,
    String? otpCode,
    bool? isLoggedIn,
  }) {
    return DeliveryAuthModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  List<Object?> get props => [phoneNumber, otpCode, isLoggedIn];
}
