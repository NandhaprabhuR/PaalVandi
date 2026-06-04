import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/partner_model.dart';
import '../repositories/auth_repository.dart';

// ─── Events ──────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthPhoneChanged extends AuthEvent {
  final String phone;
  const AuthPhoneChanged(this.phone);
  @override
  List<Object?> get props => [phone];
}

class AuthOtpChanged extends AuthEvent {
  final String otp;
  const AuthOtpChanged(this.otp);
  @override
  List<Object?> get props => [otp];
}

class AuthPhoneSubmitted extends AuthEvent {
  const AuthPhoneSubmitted();
}

class AuthOtpSubmitted extends AuthEvent {
  const AuthOtpSubmitted();
}

class AuthLogout extends AuthEvent {
  const AuthLogout();
}

// ─── States ──────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  final String phone;
  final String otp;
  final PartnerModel? partner;

  const AuthState({this.phone = '', this.otp = '', this.partner});

  @override
  List<Object?> get props => [phone, otp, partner];
}

class AuthInitial extends AuthState {
  const AuthInitial({super.phone});
}

class AuthLoading extends AuthState {
  const AuthLoading({super.phone, super.otp});
}

class AuthCodeSent extends AuthState {
  const AuthCodeSent({required super.phone, super.otp});
}

class AuthAccessDenied extends AuthState {
  const AuthAccessDenied({required super.phone});
}

class AuthSuccess extends AuthState {
  const AuthSuccess({required super.phone, required super.partner});
}

class AuthFailure extends AuthState {
  final String error;
  const AuthFailure({required super.phone, super.otp, required this.error});
  @override
  List<Object?> get props => [phone, otp, error];
}

// ─── ViewModel (BLoC) ───────────────────────────────────────
class AuthViewModel extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthViewModel({AuthRepository? repository})
      : _repository = repository ?? MockAuthRepository(),
        super(const AuthInitial()) {
    on<AuthPhoneChanged>(_onPhoneChanged);
    on<AuthOtpChanged>(_onOtpChanged);
    on<AuthPhoneSubmitted>(_onPhoneSubmitted);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthLogout>(_onLogout);
  }

  void _onPhoneChanged(AuthPhoneChanged event, Emitter<AuthState> emit) {
    emit(AuthInitial(phone: event.phone));
  }

  void _onOtpChanged(AuthOtpChanged event, Emitter<AuthState> emit) {
    emit(AuthCodeSent(phone: state.phone, otp: event.otp));
  }

  Future<void> _onPhoneSubmitted(
      AuthPhoneSubmitted event, Emitter<AuthState> emit) async {
    final phone = state.phone.trim();
    if (phone.length != 10) {
      emit(AuthFailure(
          phone: phone, error: 'Please enter a valid 10-digit mobile number.'));
      return;
    }

    emit(AuthLoading(phone: phone));

    // Send OTP
    await _repository.sendOtp(phone);
    emit(AuthCodeSent(phone: phone));
  }

  Future<void> _onOtpSubmitted(
      AuthOtpSubmitted event, Emitter<AuthState> emit) async {
    final otp = state.otp.trim();
    if (otp.length != 6) {
      emit(AuthFailure(
          phone: state.phone,
          otp: otp,
          error: 'Please enter the 6-digit code.'));
      return;
    }

    emit(AuthLoading(phone: state.phone, otp: otp));

    final isValid = await _repository.verifyOtp(state.phone, otp);
    if (!isValid) {
      emit(AuthFailure(
          phone: state.phone, otp: otp, error: 'Invalid OTP. Please try again.'));
      return;
    }

    final partner = _repository.getPartnerProfile();
    emit(AuthSuccess(phone: state.phone, partner: partner));
  }

  void _onLogout(AuthLogout event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }
}
