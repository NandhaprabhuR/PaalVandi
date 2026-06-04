import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/notification_model.dart';

// ─── Events ──────────────────────────────────────────────────
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

class MarkNotificationRead extends NotificationEvent {
  final String id;
  const MarkNotificationRead(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearNotificationHistory extends NotificationEvent {
  const ClearNotificationHistory();
}

// ─── State ───────────────────────────────────────────────────
class NotificationState extends Equatable {
  final bool isLoading;
  final List<AppNotification> notifications;

  const NotificationState({
    this.isLoading = true,
    this.notifications = const [],
  });

  NotificationState copyWith({
    bool? isLoading,
    List<AppNotification>? notifications,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [isLoading, notifications];
}

// ─── ViewModel (BLoC) ───────────────────────────────────────
class NotificationViewModel extends Bloc<NotificationEvent, NotificationState> {
  NotificationViewModel() : super(const NotificationState()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkRead);
    on<ClearNotificationHistory>(_onClear);
  }

  Future<void> _onLoad(
      LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    // Simulate slight loading delay for skeleton UI verification
    await Future.delayed(const Duration(milliseconds: 300));

    // Seed mock data
    final list = [
      AppNotification(
        id: 'NOT-001',
        title: 'New Daily Order Assigned',
        message: 'Order PV-7842 for Nandha Prabhu has been assigned to you.',
        type: NotificationType.orderAssigned,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        orderId: 'PV-7842',
      ),
      AppNotification(
        id: 'NOT-002',
        title: 'New Daily Order Assigned',
        message: 'Order PV-7843 for Anjali Sharma has been assigned to you.',
        type: NotificationType.orderAssigned,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        orderId: 'PV-7843',
      ),
      AppNotification(
        id: 'NOT-003',
        title: 'Subscription Stop Assigned',
        message: 'Morning delivery SUB-001 for Rajesh Kumar is waiting for collection.',
        type: NotificationType.subscriptionAssigned,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'NOT-004',
        title: 'Bulk Order Assigned',
        message: 'Hotel order BLK-101 for Hotel Temple Towers has been assigned to you.',
        type: NotificationType.bulkOrderAssigned,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'NOT-005',
        title: 'Bottle Collection Stop',
        message: 'Collect pending bottles from BTL-001 at Gandhipuram today.',
        type: NotificationType.bottleCollectionAssigned,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];

    emit(state.copyWith(isLoading: false, notifications: list));
  }

  void _onMarkRead(MarkNotificationRead event, Emitter<NotificationState> emit) {
    final updated = state.notifications.map((n) {
      if (n.id == event.id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    emit(state.copyWith(notifications: updated));
  }

  void _onClear(ClearNotificationHistory event, Emitter<NotificationState> emit) {
    emit(state.copyWith(notifications: const []));
  }
}
