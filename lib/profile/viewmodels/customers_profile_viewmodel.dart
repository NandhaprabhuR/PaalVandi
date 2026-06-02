import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customers_profile_model.dart';
import '../../core/services/haptic_service.dart';

// Events
abstract class CustomersProfileEvent extends Equatable {
  const CustomersProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileFieldChanged extends CustomersProfileEvent {
  final String? name;
  final String? houseNo;
  final String? apartmentName;
  final String? street;
  final String? pincode;
  final String? referralCode;
  final String? deliveryPreference;
  final String? profilePhoto;
  final String? preferredDeliveryTime;
  final bool? enablePushNotification;
  final bool? enableWhatsAppNotification;
  final bool? enableSmsNotification;
  final String? emergencyContact;
  final bool? enableHapticFeedback;
  final bool? enableOrderUpdates;
  final bool? enableSubscriptionReminders;
  final bool? enablePromotionalOffers;

  const ProfileFieldChanged({
    this.name,
    this.houseNo,
    this.apartmentName,
    this.street,
    this.pincode,
    this.referralCode,
    this.deliveryPreference,
    this.profilePhoto,
    this.preferredDeliveryTime,
    this.enablePushNotification,
    this.enableWhatsAppNotification,
    this.enableSmsNotification,
    this.emergencyContact,
    this.enableHapticFeedback,
    this.enableOrderUpdates,
    this.enableSubscriptionReminders,
    this.enablePromotionalOffers,
  });

  @override
  List<Object?> get props => [
        name,
        houseNo,
        apartmentName,
        street,
        pincode,
        referralCode,
        deliveryPreference,
        profilePhoto,
        preferredDeliveryTime,
        enablePushNotification,
        enableWhatsAppNotification,
        enableSmsNotification,
        emergencyContact,
        enableHapticFeedback,
        enableOrderUpdates,
        enableSubscriptionReminders,
        enablePromotionalOffers,
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
  // ignore: unused_field
  final dynamic _supabase;

  CustomersProfileViewModel(this._supabase)
      : super(ProfileInitial(CustomersProfileModel(
          enableHapticFeedback: HapticService.hapticsEnabled,
          enablePushNotification: HapticService.pushEnabled,
          enableOrderUpdates: HapticService.orderEnabled,
          enableSubscriptionReminders: HapticService.remindersEnabled,
          enablePromotionalOffers: HapticService.promoEnabled,
        ))) {
    on<ProfileFieldChanged>((event, emit) {
      final updatedModel = state.model.copyWith(
        name: event.name,
        houseNo: event.houseNo,
        apartmentName: event.apartmentName,
        street: event.street,
        pincode: event.pincode,
        referralCode: event.referralCode,
        deliveryPreference: event.deliveryPreference,
        profilePhoto: event.profilePhoto,
        preferredDeliveryTime: event.preferredDeliveryTime,
        enablePushNotification: event.enablePushNotification,
        enableWhatsAppNotification: event.enableWhatsAppNotification,
        enableSmsNotification: event.enableSmsNotification,
        emergencyContact: event.emergencyContact,
        enableHapticFeedback: event.enableHapticFeedback,
        enableOrderUpdates: event.enableOrderUpdates,
        enableSubscriptionReminders: event.enableSubscriptionReminders,
        enablePromotionalOffers: event.enablePromotionalOffers,
      );

      // Perform local SharedPreferences side effects and update global service flags
      if (event.enableHapticFeedback != null) {
        HapticService.setEnabled(event.enableHapticFeedback!);
      }
      if (event.enablePushNotification != null) {
        HapticService.savePreference(HapticService.pushKey, event.enablePushNotification!);
        HapticService.pushEnabled = event.enablePushNotification!;
      }
      if (event.enableOrderUpdates != null) {
        HapticService.savePreference(HapticService.orderKey, event.enableOrderUpdates!);
        HapticService.orderEnabled = event.enableOrderUpdates!;
      }
      if (event.enableSubscriptionReminders != null) {
        HapticService.savePreference(HapticService.remindersKey, event.enableSubscriptionReminders!);
        HapticService.remindersEnabled = event.enableSubscriptionReminders!;
      }
      if (event.enablePromotionalOffers != null) {
        HapticService.savePreference(HapticService.promoKey, event.enablePromotionalOffers!);
        HapticService.promoEnabled = event.enablePromotionalOffers!;
      }

      emit(ProfileInitial(updatedModel));
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
