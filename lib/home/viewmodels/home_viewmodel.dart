import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../orders/models/daily_order_model.dart';
import '../../subscriptions/models/subscription_delivery_model.dart';
import '../../bulk_orders/models/bulk_order_model.dart';
import '../../bottles/models/bottle_collection_model.dart';
import '../../core/constants/mock_data.dart';

// ─── Events ──────────────────────────────────────────────────
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomeDashboard extends HomeEvent {
  const LoadHomeDashboard();
}

// ─── State ───────────────────────────────────────────────────
class HomeState extends Equatable {
  final bool isLoading;
  final String partnerName;

  // Summary counts
  final int totalOrders;
  final int dailyOrders;
  final int subscriptionDeliveries;
  final int bulkOrders;
  final int bottleCollections;
  final int completedDeliveries;
  final int pendingDeliveries;

  // Revenue stats
  final int ordersDelivered;
  final double milkQuantityDelivered;
  final int bottleCollectionsToday;
  final double distanceCovered;

  const HomeState({
    this.isLoading = true,
    this.partnerName = 'Partner',
    this.totalOrders = 0,
    this.dailyOrders = 0,
    this.subscriptionDeliveries = 0,
    this.bulkOrders = 0,
    this.bottleCollections = 0,
    this.completedDeliveries = 0,
    this.pendingDeliveries = 0,
    this.ordersDelivered = 0,
    this.milkQuantityDelivered = 0,
    this.bottleCollectionsToday = 0,
    this.distanceCovered = 0,
  });

  HomeState copyWith({
    bool? isLoading,
    String? partnerName,
    int? totalOrders,
    int? dailyOrders,
    int? subscriptionDeliveries,
    int? bulkOrders,
    int? bottleCollections,
    int? completedDeliveries,
    int? pendingDeliveries,
    int? ordersDelivered,
    double? milkQuantityDelivered,
    int? bottleCollectionsToday,
    double? distanceCovered,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      partnerName: partnerName ?? this.partnerName,
      totalOrders: totalOrders ?? this.totalOrders,
      dailyOrders: dailyOrders ?? this.dailyOrders,
      subscriptionDeliveries: subscriptionDeliveries ?? this.subscriptionDeliveries,
      bulkOrders: bulkOrders ?? this.bulkOrders,
      bottleCollections: bottleCollections ?? this.bottleCollections,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      pendingDeliveries: pendingDeliveries ?? this.pendingDeliveries,
      ordersDelivered: ordersDelivered ?? this.ordersDelivered,
      milkQuantityDelivered: milkQuantityDelivered ?? this.milkQuantityDelivered,
      bottleCollectionsToday: bottleCollectionsToday ?? this.bottleCollectionsToday,
      distanceCovered: distanceCovered ?? this.distanceCovered,
    );
  }

  @override
  List<Object?> get props => [
        isLoading, partnerName, totalOrders, dailyOrders,
        subscriptionDeliveries, bulkOrders, bottleCollections,
        completedDeliveries, pendingDeliveries, ordersDelivered,
        milkQuantityDelivered, bottleCollectionsToday, distanceCovered,
      ];
}

// ─── ViewModel (BLoC) ───────────────────────────────────────
class HomeViewModel extends Bloc<HomeEvent, HomeState> {
  HomeViewModel() : super(const HomeState()) {
    on<LoadHomeDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
      LoadHomeDashboard event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 600));

    final List<DailyOrderModel> orders = MockData.dailyOrders;
    final List<SubscriptionDeliveryModel> subs = MockData.subscriptionDeliveries;
    final List<BulkOrderModel> bulks = MockData.bulkOrders;
    final List<BottleCollectionModel> bottles = MockData.bottleCollections;

    final activeSubs = subs.where((s) => s.status == 'Active').toList();
    final totalAll = orders.length + activeSubs.length + bulks.length;
    final completed = 3; // mock completed count
    final pending = totalAll - completed;

    // Calculate total milk qty from orders
    double totalMilk = 0;
    for (final o in orders) {
      totalMilk += o.milkQty;
    }

    emit(state.copyWith(
      isLoading: false,
      partnerName: MockData.partnerProfile.name,
      totalOrders: totalAll,
      dailyOrders: orders.length,
      subscriptionDeliveries: activeSubs.length,
      bulkOrders: bulks.length,
      bottleCollections: bottles.length,
      completedDeliveries: completed,
      pendingDeliveries: pending,
      ordersDelivered: completed,
      milkQuantityDelivered: totalMilk,
      bottleCollectionsToday: 2,
      distanceCovered: 14.5,
    ));
  }
}
