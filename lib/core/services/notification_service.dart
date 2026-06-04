import '../../notifications/models/notification_model.dart';

/// Cross-app notification bridge service.
/// Currently stores notifications locally; backend-ready interface
/// for Supabase real-time or FCM integration later.
abstract class NotificationService {
  Future<void> notifyCustomer(AppNotification notification);
  Future<void> notifyPartner(AppNotification notification);
  List<AppNotification> getPartnerNotifications();
  List<AppNotification> getCustomerNotifications();
  void clearAll();
}

class MockNotificationService implements NotificationService {
  final List<AppNotification> _partnerNotifications = [];
  final List<AppNotification> _customerNotifications = [];

  @override
  Future<void> notifyCustomer(AppNotification notification) async {
    _customerNotifications.insert(0, notification);
  }

  @override
  Future<void> notifyPartner(AppNotification notification) async {
    _partnerNotifications.insert(0, notification);
  }

  @override
  List<AppNotification> getPartnerNotifications() =>
      List.unmodifiable(_partnerNotifications);

  @override
  List<AppNotification> getCustomerNotifications() =>
      List.unmodifiable(_customerNotifications);

  @override
  void clearAll() {
    _partnerNotifications.clear();
    _customerNotifications.clear();
  }
}
