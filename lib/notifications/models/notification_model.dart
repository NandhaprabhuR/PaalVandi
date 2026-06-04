import 'package:equatable/equatable.dart';

/// Notification model shared between Customer and Delivery Partner apps.
enum NotificationType {
  orderAssigned,
  orderOnTheWay,
  orderDelivered,
  bottleCollected,
  subscriptionDelivered,
  subscriptionAssigned,
  bulkOrderAssigned,
  bulkOrderDelivered,
  bottleCollectionAssigned,
}

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? orderId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.orderId,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      orderId: orderId,
    );
  }

  @override
  List<Object?> get props => [id, title, message, type, timestamp, isRead, orderId];
}
