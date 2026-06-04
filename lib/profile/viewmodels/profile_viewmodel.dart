import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/haptic_service.dart';

// ─── Events ──────────────────────────────────────────────────
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ToggleHapticFeedback extends ProfileEvent {
  const ToggleHapticFeedback();
}

class ToggleNotifications extends ProfileEvent {
  const ToggleNotifications();
}

class ToggleDarkMode extends ProfileEvent {
  const ToggleDarkMode();
}

// ─── State ───────────────────────────────────────────────────
class ProfileState extends Equatable {
  final bool hapticEnabled;
  final bool notificationsEnabled;
  final bool darkModeEnabled;

  // Stats
  final int todayDeliveries;
  final int monthlyDeliveries;
  final int bottleCollections;
  final int subscriptionDeliveries;

  const ProfileState({
    this.hapticEnabled = true,
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.todayDeliveries = 3,
    this.monthlyDeliveries = 87,
    this.bottleCollections = 24,
    this.subscriptionDeliveries = 56,
  });

  ProfileState copyWith({
    bool? hapticEnabled,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
  }) {
    return ProfileState(
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      todayDeliveries: todayDeliveries,
      monthlyDeliveries: monthlyDeliveries,
      bottleCollections: bottleCollections,
      subscriptionDeliveries: subscriptionDeliveries,
    );
  }

  @override
  List<Object?> get props => [
        hapticEnabled, notificationsEnabled, darkModeEnabled,
        todayDeliveries, monthlyDeliveries, bottleCollections,
        subscriptionDeliveries,
      ];
}

// ─── ViewModel (BLoC) ───────────────────────────────────────
class ProfileViewModel extends Bloc<ProfileEvent, ProfileState> {
  ProfileViewModel() : super(const ProfileState()) {
    on<ToggleHapticFeedback>((event, emit) {
      final newValue = !state.hapticEnabled;
      HapticService.setEnabled(newValue);
      emit(state.copyWith(hapticEnabled: newValue));
    });

    on<ToggleNotifications>((event, emit) {
      emit(state.copyWith(notificationsEnabled: !state.notificationsEnabled));
    });

    on<ToggleDarkMode>((event, emit) {
      emit(state.copyWith(darkModeEnabled: !state.darkModeEnabled));
    });
  }
}
