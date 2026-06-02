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
  final String profilePhoto;
  final String preferredDeliveryTime;
  final bool enablePushNotification;
  final bool enableWhatsAppNotification;
  final bool enableSmsNotification;
  final String emergencyContact;
  final bool enableHapticFeedback;
  final bool enableOrderUpdates;
  final bool enableSubscriptionReminders;
  final bool enablePromotionalOffers;

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
    this.profilePhoto = '👩‍🦰',
    this.preferredDeliveryTime = 'Morning (6:00 AM – 8:00 AM)',
    this.enablePushNotification = true,
    this.enableWhatsAppNotification = true,
    this.enableSmsNotification = false,
    this.emergencyContact = '',
    this.enableHapticFeedback = true,
    this.enableOrderUpdates = true,
    this.enableSubscriptionReminders = true,
    this.enablePromotionalOffers = true,
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
    String? profilePhoto,
    String? preferredDeliveryTime,
    bool? enablePushNotification,
    bool? enableWhatsAppNotification,
    bool? enableSmsNotification,
    String? emergencyContact,
    bool? enableHapticFeedback,
    bool? enableOrderUpdates,
    bool? enableSubscriptionReminders,
    bool? enablePromotionalOffers,
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
      profilePhoto: profilePhoto ?? this.profilePhoto,
      preferredDeliveryTime: preferredDeliveryTime ?? this.preferredDeliveryTime,
      enablePushNotification: enablePushNotification ?? this.enablePushNotification,
      enableWhatsAppNotification: enableWhatsAppNotification ?? this.enableWhatsAppNotification,
      enableSmsNotification: enableSmsNotification ?? this.enableSmsNotification,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableOrderUpdates: enableOrderUpdates ?? this.enableOrderUpdates,
      enableSubscriptionReminders: enableSubscriptionReminders ?? this.enableSubscriptionReminders,
      enablePromotionalOffers: enablePromotionalOffers ?? this.enablePromotionalOffers,
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
