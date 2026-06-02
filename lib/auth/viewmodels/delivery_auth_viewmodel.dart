import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/delivery_auth_model.dart';

// Events
abstract class DeliveryAuthEvent extends Equatable {
  const DeliveryAuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthPhoneChanged extends DeliveryAuthEvent {
  final String phone;
  const AuthPhoneChanged(this.phone);
  @override
  List<Object?> get props => [phone];
}

class AuthOtpChanged extends DeliveryAuthEvent {
  final String otp;
  const AuthOtpChanged(this.otp);
  @override
  List<Object?> get props => [otp];
}

class AuthPhoneSubmitted extends DeliveryAuthEvent {
  const AuthPhoneSubmitted();
}

class AuthOtpSubmitted extends DeliveryAuthEvent {
  const AuthOtpSubmitted();
}

class AuthLogout extends DeliveryAuthEvent {
  const AuthLogout();
}

// States
abstract class DeliveryAuthState extends Equatable {
  final DeliveryAuthModel model;
  const DeliveryAuthState(this.model);
  @override
  List<Object?> get props => [model];
}

class AuthInitial extends DeliveryAuthState {
  const AuthInitial(super.model);
}

class AuthLoading extends DeliveryAuthState {
  const AuthLoading(super.model);
}

class AuthCodeSent extends DeliveryAuthState {
  const AuthCodeSent(super.model);
}

class AuthSuccess extends DeliveryAuthState {
  const AuthSuccess(super.model);
}

class AuthFailure extends DeliveryAuthState {
  final String error;
  const AuthFailure(super.model, this.error);
  @override
  List<Object?> get props => [model, error];
}

// ViewModel (BLoC)
class DeliveryAuthViewModel extends Bloc<DeliveryAuthEvent, DeliveryAuthState> {
  DeliveryAuthViewModel() : super(const AuthInitial(DeliveryAuthModel())) {
    
    on<AuthPhoneChanged>((event, emit) {
      emit(AuthInitial(state.model.copyWith(phoneNumber: event.phone)));
    });

    on<AuthOtpChanged>((event, emit) {
      emit(AuthCodeSent(state.model.copyWith(otpCode: event.otp)));
    });

    on<AuthPhoneSubmitted>((event, emit) async {
      final phone = state.model.phoneNumber.trim();
      if (phone.length != 10) {
        emit(AuthFailure(state.model, 'Please enter a valid 10-digit mobile number.'));
        return;
      }
      
      emit(AuthLoading(state.model));
      await Future.delayed(const Duration(milliseconds: 800));
      emit(AuthCodeSent(state.model));
    });

    on<AuthOtpSubmitted>((event, emit) async {
      final otp = state.model.otpCode.trim();
      if (otp.length != 6) {
        emit(AuthFailure(state.model, 'Please enter the 6-digit code.'));
        return;
      }

      emit(AuthLoading(state.model));
      await Future.delayed(const Duration(milliseconds: 1000));
      emit(AuthSuccess(state.model.copyWith(isLoggedIn: true)));
    });

    on<AuthLogout>((event, emit) {
      emit(const AuthInitial(DeliveryAuthModel()));
    });
  }
}
