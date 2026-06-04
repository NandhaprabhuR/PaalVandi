import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/daily_order_model.dart';
import '../repositories/order_repository.dart';

// ─── Events ──────────────────────────────────────────────────
abstract class OrdersEvent extends Equatable {
  const OrdersEvent();
  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {
  const LoadOrders();
}

class MarkOrderDelivered extends OrdersEvent {
  final String orderId;
  const MarkOrderDelivered(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class UpdateOrderStatus extends OrdersEvent {
  final String orderId;
  final String newStatus;
  const UpdateOrderStatus(this.orderId, this.newStatus);
  @override
  List<Object?> get props => [orderId, newStatus];
}

// ─── State ───────────────────────────────────────────────────
class OrdersState extends Equatable {
  final bool isLoading;
  final List<DailyOrderModel> orders;
  final String? deliveredOrderId; // for success feedback

  const OrdersState({
    this.isLoading = true,
    this.orders = const [],
    this.deliveredOrderId,
  });

  OrdersState copyWith({
    bool? isLoading,
    List<DailyOrderModel>? orders,
    String? deliveredOrderId,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      deliveredOrderId: deliveredOrderId,
    );
  }

  @override
  List<Object?> get props => [isLoading, orders, deliveredOrderId];
}

// ─── ViewModel (BLoC) ───────────────────────────────────────
class OrdersViewModel extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository _repository;

  OrdersViewModel({OrderRepository? repository})
      : _repository = repository ?? MockOrderRepository(),
        super(const OrdersState()) {
    on<LoadOrders>(_onLoadOrders);
    on<MarkOrderDelivered>(_onMarkDelivered);
    on<UpdateOrderStatus>(_onUpdateStatus);
  }

  Future<void> _onLoadOrders(
      LoadOrders event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(isLoading: true));
    final orders = await _repository.fetchTodayOrders();
    emit(state.copyWith(isLoading: false, orders: orders));
  }

  Future<void> _onMarkDelivered(
      MarkOrderDelivered event, Emitter<OrdersState> emit) async {
    final updated = await _repository.updateOrderStatus(event.orderId, 'Delivered');
    final newList = state.orders
        .map((o) => o.orderId == event.orderId ? updated : o)
        .toList();
    emit(state.copyWith(orders: newList, deliveredOrderId: event.orderId));
    // Clear success feedback after emitting
    emit(state.copyWith(deliveredOrderId: null));
  }

  Future<void> _onUpdateStatus(
      UpdateOrderStatus event, Emitter<OrdersState> emit) async {
    final updated =
        await _repository.updateOrderStatus(event.orderId, event.newStatus);
    final newList = state.orders
        .map((o) => o.orderId == event.orderId ? updated : o)
        .toList();
    emit(state.copyWith(orders: newList));
  }
}
