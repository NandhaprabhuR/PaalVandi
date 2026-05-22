import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'customers_login_model.dart';

// Events
abstract class CustomersLoginEvent extends Equatable {
  const CustomersLoginEvent();
  @override
  List<Object> get props => [];
}

class LoginPhoneNumberChanged extends CustomersLoginEvent {
  final String phoneNumber;
  const LoginPhoneNumberChanged(this.phoneNumber);
  @override
  List<Object> get props => [phoneNumber];
}

class LoginSendOtpSubmitted extends CustomersLoginEvent {}

// States
abstract class CustomersLoginState extends Equatable {
  final CustomersLoginModel model;
  const CustomersLoginState(this.model);
  @override
  List<Object> get props => [model];
}

class LoginInitial extends CustomersLoginState {
  const LoginInitial(super.model);
}

class LoginLoading extends CustomersLoginState {
  const LoginLoading(super.model);
}

class LoginOtpSent extends CustomersLoginState {
  final String phoneNumber;
  const LoginOtpSent(super.model, this.phoneNumber);
  @override
  List<Object> get props => [model, phoneNumber];
}

class LoginFailure extends CustomersLoginState {
  final String error;
  const LoginFailure(super.model, this.error);
  @override
  List<Object> get props => [model, error];
}

// ViewModel (BLoC)
class CustomersLoginViewModel extends Bloc<CustomersLoginEvent, CustomersLoginState> {
  final dynamic _supabase; // Changed from SupabaseClient to dynamic for mocking

  CustomersLoginViewModel(this._supabase) : super(const LoginInitial(CustomersLoginModel())) {
    on<LoginPhoneNumberChanged>((event, emit) {
      emit(LoginInitial(state.model.copyWith(phoneNumber: event.phoneNumber)));
    });

    on<LoginSendOtpSubmitted>((event, emit) async {
      final phone = state.model.phoneNumber.trim();
      if (phone.isEmpty) {
        emit(LoginFailure(state.model, 'Please enter a valid phone number'));
        return;
      }

      emit(LoginLoading(state.model));
      try {
        // MOCK SUPABASE CALL
        await Future.delayed(const Duration(seconds: 1));
        emit(LoginOtpSent(state.model, phone));
      } catch (e) {
        emit(LoginFailure(state.model, 'An unexpected error occurred.'));
      }
    });
  }
}
