import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/subscription_delivery_model.dart';
import '../services/subscription_billing_engine.dart';
import '../repositories/subscription_repository.dart';

// ─── Events ──────────────────────────────────────────────────
abstract class SubscriptionsEvent extends Equatable {
  const SubscriptionsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSubscriptions extends SubscriptionsEvent {
  const LoadSubscriptions();
}

class MarkSubscriptionDelivered extends SubscriptionsEvent {
  final String id;
  const MarkSubscriptionDelivered(this.id);
  @override
  List<Object?> get props => [id];
}

class SkipSubscriptionDelivery extends SubscriptionsEvent {
  final String id;
  final String reason;
  const SkipSubscriptionDelivery(this.id, this.reason);
  @override
  List<Object?> get props => [id, reason];
}

class StartRoute extends SubscriptionsEvent {
  final String routeName;
  const StartRoute(this.routeName);
  @override
  List<Object?> get props => [routeName];
}

class FinishRoute extends SubscriptionsEvent {
  final String routeName;
  const FinishRoute(this.routeName);
  @override
  List<Object?> get props => [routeName];
}

class CollectSubscriptionBottles extends SubscriptionsEvent {
  final String id;
  final int count;
  const CollectSubscriptionBottles(this.id, this.count);
  @override
  List<Object?> get props => [id, count];
}

// Billing Accounting System Events
class LoadBillingDetails extends SubscriptionsEvent {
  final String subscriptionId;
  final int month;
  final int year;
  const LoadBillingDetails(this.subscriptionId, this.month, this.year);
  @override
  List<Object?> get props => [subscriptionId, month, year];
}

class LoadBillingHistory extends SubscriptionsEvent {
  final String subscriptionId;
  const LoadBillingHistory(this.subscriptionId);
  @override
  List<Object?> get props => [subscriptionId];
}

class LoadSummaryReport extends SubscriptionsEvent {
  final int month;
  final int year;
  const LoadSummaryReport(this.month, this.year);
  @override
  List<Object?> get props => [month, year];
}

// ─── State ───────────────────────────────────────────────────
class SubscriptionsState extends Equatable {
  final bool isLoading;
  final List<SubscriptionDeliveryModel> subscriptions;
  final String? deliveredId;
  final Map<String, String> routeStatuses; // 'Not Started' | 'In Progress' | 'Completed'
  
  // Billing state extensions
  final bool isBillingLoading;
  final BillingStatement? activeStatement;
  final List<BillingStatement> billingHistory;
  final BillingSummaryReport? summaryReport;

  const SubscriptionsState({
    this.isLoading = true,
    this.subscriptions = const [],
    this.deliveredId,
    this.routeStatuses = const {
      'Vadavalli Route': 'Not Started',
      'Saibaba Colony Route': 'Not Started',
      'RS Puram Route': 'Not Started',
    },
    this.isBillingLoading = false,
    this.activeStatement,
    this.billingHistory = const [],
    this.summaryReport,
  });

  List<SubscriptionDeliveryModel> get morningDeliveries =>
      subscriptions.where((s) => s.timing == 'Morning').toList();

  List<SubscriptionDeliveryModel> get eveningDeliveries =>
      subscriptions.where((s) => s.timing == 'Evening').toList();

  SubscriptionsState copyWith({
    bool? isLoading,
    List<SubscriptionDeliveryModel>? subscriptions,
    String? deliveredId,
    Map<String, String>? routeStatuses,
    bool? isBillingLoading,
    BillingStatement? activeStatement,
    List<BillingStatement>? billingHistory,
    BillingSummaryReport? summaryReport,
  }) {
    return SubscriptionsState(
      isLoading: isLoading ?? this.isLoading,
      subscriptions: subscriptions ?? this.subscriptions,
      deliveredId: deliveredId,
      routeStatuses: routeStatuses ?? this.routeStatuses,
      isBillingLoading: isBillingLoading ?? this.isBillingLoading,
      activeStatement: activeStatement ?? this.activeStatement,
      billingHistory: billingHistory ?? this.billingHistory,
      summaryReport: summaryReport ?? this.summaryReport,
    );
  }

  @override
  List<Object?> get props => [
        isLoading, 
        subscriptions, 
        deliveredId, 
        routeStatuses,
        isBillingLoading,
        activeStatement,
        billingHistory,
        summaryReport,
      ];
}

// ─── ViewModel (BLoC) ───────────────────────────────────────
class SubscriptionsViewModel
    extends Bloc<SubscriptionsEvent, SubscriptionsState> {
  final SubscriptionRepository _repository;

  SubscriptionsViewModel({SubscriptionRepository? repository})
      : _repository = repository ?? MockSubscriptionRepository(),
        super(const SubscriptionsState()) {
    on<LoadSubscriptions>(_onLoad);
    on<MarkSubscriptionDelivered>(_onDeliver);
    on<SkipSubscriptionDelivery>(_onSkip);
    on<StartRoute>(_onStartRoute);
    on<FinishRoute>(_onFinishRoute);
    on<CollectSubscriptionBottles>(_onCollectBottles);
    on<LoadBillingDetails>(_onLoadBillingDetails);
    on<LoadBillingHistory>(_onLoadBillingHistory);
    on<LoadSummaryReport>(_onLoadSummaryReport);
  }

  Future<void> _onLoad(
      LoadSubscriptions event, Emitter<SubscriptionsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final subs = await _repository.fetchTodaySubscriptions();
    emit(state.copyWith(isLoading: false, subscriptions: subs));
  }

  Future<void> _onDeliver(
      MarkSubscriptionDelivered event, Emitter<SubscriptionsState> emit) async {
    final updated = await _repository.markDelivered(event.id);
    final newList = state.subscriptions
        .map((s) => s.id == event.id ? updated : s)
        .toList();
    emit(state.copyWith(subscriptions: newList, deliveredId: event.id));
    emit(state.copyWith(deliveredId: null));
  }

  Future<void> _onSkip(
      SkipSubscriptionDelivery event, Emitter<SubscriptionsState> emit) async {
    final updated = await _repository.skipDeliveryWithReason(event.id, event.reason);
    final newList = state.subscriptions
        .map((s) => s.id == event.id ? updated : s)
        .toList();
    emit(state.copyWith(subscriptions: newList));
  }

  void _onStartRoute(StartRoute event, Emitter<SubscriptionsState> emit) {
    final newStatuses = Map<String, String>.from(state.routeStatuses);
    newStatuses[event.routeName] = 'In Progress';
    emit(state.copyWith(routeStatuses: newStatuses));
  }

  void _onFinishRoute(FinishRoute event, Emitter<SubscriptionsState> emit) {
    final newStatuses = Map<String, String>.from(state.routeStatuses);
    newStatuses[event.routeName] = 'Completed';
    emit(state.copyWith(routeStatuses: newStatuses));
  }

  Future<void> _onCollectBottles(
      CollectSubscriptionBottles event, Emitter<SubscriptionsState> emit) async {
    final updated = await _repository.collectBottles(event.id, event.count);
    final newList = state.subscriptions
        .map((s) => s.id == event.id ? updated : s)
        .toList();
    emit(state.copyWith(subscriptions: newList));
  }

  Future<void> _onLoadBillingDetails(
      LoadBillingDetails event, Emitter<SubscriptionsState> emit) async {
    emit(state.copyWith(isBillingLoading: true));
    
    final profile = await _repository.fetchBillingProfile(event.subscriptionId);
    final ledger = await _repository.fetchLedger(event.subscriptionId);
    
    final statement = SubscriptionBillingEngine.calculateStatement(
      profile, 
      ledger, 
      event.month, 
      event.year,
    );

    emit(state.copyWith(
      isBillingLoading: false,
      activeStatement: statement,
    ));
  }

  Future<void> _onLoadBillingHistory(
      LoadBillingHistory event, Emitter<SubscriptionsState> emit) async {
    emit(state.copyWith(isBillingLoading: true));
    
    final profile = await _repository.fetchBillingProfile(event.subscriptionId);
    final ledger = await _repository.fetchLedger(event.subscriptionId);
    
    // Calculate statement history for January to June 2026
    final List<BillingStatement> history = [];
    final months = [
      _MonthYear(1, 2026),
      _MonthYear(2, 2026),
      _MonthYear(3, 2026),
      _MonthYear(4, 2026),
      _MonthYear(5, 2026),
      _MonthYear(6, 2026),
    ];

    for (final my in months) {
      final stmt = SubscriptionBillingEngine.calculateStatement(
        profile, 
        ledger, 
        my.month, 
        my.year,
      );
      history.add(stmt);
    }

    emit(state.copyWith(
      isBillingLoading: false,
      billingHistory: history,
    ));
  }

  Future<void> _onLoadSummaryReport(
      LoadSummaryReport event, Emitter<SubscriptionsState> emit) async {
    emit(state.copyWith(isBillingLoading: true));
    
    final List<BillingStatement> stmts = [];
    final subs = await _repository.fetchTodaySubscriptions();
    
    for (final sub in subs) {
      final profile = await _repository.fetchBillingProfile(sub.id);
      final ledger = await _repository.fetchLedger(sub.id);
      
      final stmt = SubscriptionBillingEngine.calculateStatement(
        profile, 
        ledger, 
        event.month, 
        event.year,
      );
      stmts.add(stmt);
    }

    final report = SubscriptionBillingEngine.calculateSummaryReport(
      stmts, 
      event.month, 
      event.year,
    );

    emit(state.copyWith(
      isBillingLoading: false,
      summaryReport: report,
    ));
  }
}

class _MonthYear {
  final int month;
  final int year;
  const _MonthYear(this.month, this.year);
}
