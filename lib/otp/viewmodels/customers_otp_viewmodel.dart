import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customers_otp_model.dart';

// Events
abstract class CustomersOtpEvent extends Equatable {
  const CustomersOtpEvent();
  @override
  List<Object> get props => [];
}

class OtpCodeChanged extends CustomersOtpEvent {
  final String otpCode;
  const OtpCodeChanged(this.otpCode);
  @override
  List<Object> get props => [otpCode];
}

class OtpVerifySubmitted extends CustomersOtpEvent {
  final String phoneNumber;
  const OtpVerifySubmitted(this.phoneNumber);
  @override
  List<Object> get props => [phoneNumber];
}

// States
abstract class CustomersOtpState extends Equatable {
  final CustomersOtpModel model;
  const CustomersOtpState(this.model);
  @override
  List<Object> get props => [model];
}

class OtpInitial extends CustomersOtpState {
  const OtpInitial(super.model);
}

class OtpLoading extends CustomersOtpState {
  const OtpLoading(super.model);
}

class OtpSuccess extends CustomersOtpState {
  final bool isProfileComplete;
  const OtpSuccess(super.model, this.isProfileComplete);
  @override
  List<Object> get props => [model, isProfileComplete];
}

class OtpFailure extends CustomersOtpState {
  final String error;
  const OtpFailure(super.model, this.error);
  @override
  List<Object> get props => [model, error];
}

// ViewModel (BLoC)
class CustomersOtpViewModel extends Bloc<CustomersOtpEvent, CustomersOtpState> {
  final dynamic _supabase;

  CustomersOtpViewModel(this._supabase) : super(const OtpInitial(CustomersOtpModel())) {
    on<OtpCodeChanged>((event, emit) {
      emit(OtpInitial(state.model.copyWith(otpCode: event.otpCode)));
    });

    on<OtpVerifySubmitted>((event, emit) async {
      final otp = state.model.otpCode.trim();
      if (otp.length != 6) {
        emit(OtpFailure(state.model, 'Please enter a valid 6-digit OTP'));
        return;
      }

      emit(OtpLoading(state.model));
      try {
        // MOCK SUPABASE CALL
        await Future.delayed(const Duration(seconds: 1));
        
        // Mocking user profile check (forcing to profile for now to test the flow)
        bool isProfileComplete = false; 
        
        emit(OtpSuccess(state.model, isProfileComplete));
      } catch (e) {
        emit(OtpFailure(state.model, 'An unexpected error occurred.'));
      }
    });
  }
}
