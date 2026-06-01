import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customers_profile_model.dart';

// Events
abstract class CustomersProfileEvent extends Equatable {
  const CustomersProfileEvent();
  @override
  List<Object> get props => [];
}

class ProfileFieldChanged extends CustomersProfileEvent {
  final String? name;
  final String? houseNo;
  final String? apartmentName;
  final String? street;
  final String? pincode;
  final String? referralCode;
  final String? deliveryPreference;

  const ProfileFieldChanged({
    this.name,
    this.houseNo,
    this.apartmentName,
    this.street,
    this.pincode,
    this.referralCode,
    this.deliveryPreference,
  });

  @override
  List<Object> get props => [
        name ?? '',
        houseNo ?? '',
        apartmentName ?? '',
        street ?? '',
        pincode ?? '',
        referralCode ?? '',
        deliveryPreference ?? '',
      ];
}

class ProfileFetchLocationRequested extends CustomersProfileEvent {
  const ProfileFetchLocationRequested();
}

class ProfileSubmit extends CustomersProfileEvent {}

// States
abstract class CustomersProfileState extends Equatable {
  final CustomersProfileModel model;
  const CustomersProfileState(this.model);
  @override
  List<Object> get props => [model];
}

class ProfileInitial extends CustomersProfileState {
  const ProfileInitial(super.model);
}

class ProfileLoading extends CustomersProfileState {
  const ProfileLoading(super.model);
}

class ProfileSuccess extends CustomersProfileState {
  const ProfileSuccess(super.model);
}

class ProfileLocationFetched extends CustomersProfileState {
  const ProfileLocationFetched(super.model);
}

class ProfileFailure extends CustomersProfileState {
  final String error;
  const ProfileFailure(super.model, this.error);
  @override
  List<Object> get props => [model, error];
}

// ViewModel (BLoC)
class CustomersProfileViewModel extends Bloc<CustomersProfileEvent, CustomersProfileState> {
  final dynamic _supabase;

  CustomersProfileViewModel(this._supabase) : super(const ProfileInitial(CustomersProfileModel())) {
    on<ProfileFieldChanged>((event, emit) {
      emit(ProfileInitial(state.model.copyWith(
        name: event.name,
        houseNo: event.houseNo,
        apartmentName: event.apartmentName,
        street: event.street,
        pincode: event.pincode,
        referralCode: event.referralCode,
        deliveryPreference: event.deliveryPreference,
      )));
    });

    on<ProfileFetchLocationRequested>((event, emit) async {
      emit(ProfileLoading(state.model));
      // Mock fetching GPS location delay
      await Future.delayed(const Duration(seconds: 1));
      
      final updatedModel = state.model.copyWith(
        fetchedLocation: 'GPS: 11.0168° N, 76.9558° E (Vadavalli)',
      );
      
      emit(ProfileLocationFetched(updatedModel));
      emit(ProfileInitial(updatedModel)); // Revert to initial state so they can continue typing
    });

    on<ProfileSubmit>((event, emit) async {
      final name = state.model.name.trim();
      final houseNo = state.model.houseNo.trim();
      final apartmentName = state.model.apartmentName.trim();
      final street = state.model.street.trim();
      final pincode = state.model.pincode.trim();
      final referralCode = state.model.referralCode.trim();
      
      // 1. Mandatory Fields Validation (everything except referral code is mandatory)
      if (name.isEmpty) {
        emit(ProfileFailure(state.model, 'Please enter your Full Name'));
        return;
      }
      if (houseNo.isEmpty) {
        emit(ProfileFailure(state.model, 'Please enter your House / Flat No'));
        return;
      }
      if (apartmentName.isEmpty) {
        emit(ProfileFailure(state.model, 'Please enter your Apartment / Building Name'));
        return;
      }
      if (street.isEmpty) {
        emit(ProfileFailure(state.model, 'Please enter your Street / Area'));
        return;
      }
      if (pincode.isEmpty) {
        emit(ProfileFailure(state.model, 'Please enter your Pincode'));
        return;
      }

      // 2. Name validation: text only (alphabets and spaces only)
      final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
      if (!nameRegex.hasMatch(name)) {
        emit(ProfileFailure(state.model, 'Full Name must contain letters only'));
        return;
      }

      // 3. Pincode validation: only number with exactly 6 digits
      final pincodeRegex = RegExp(r'^\d{6}$');
      if (!pincodeRegex.hasMatch(pincode)) {
        emit(ProfileFailure(state.model, 'Pincode must be exactly 6 digits'));
        return;
      }

      // 4. Referral Code validation: exactly 7 alphanumeric characters (optional)
      if (referralCode.isNotEmpty) {
        final refRegex = RegExp(r'^[a-zA-Z0-9]{7}$');
        if (!refRegex.hasMatch(referralCode)) {
          emit(ProfileFailure(state.model, 'Referral Code must be exactly 7 alphanumeric characters'));
          return;
        }
      }

      emit(ProfileLoading(state.model));
      try {
        // MOCK SUPABASE CALL
        await Future.delayed(const Duration(seconds: 1));
        emit(ProfileSuccess(state.model));
      } catch (e) {
        emit(ProfileFailure(state.model, 'Failed to update profile.'));
      }
    });
  }
}
