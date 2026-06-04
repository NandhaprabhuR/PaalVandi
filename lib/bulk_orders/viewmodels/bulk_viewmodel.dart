import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/bulk_order_model.dart';
import '../repositories/bulk_repository.dart';

// ─── Events ──────────────────────────────────────────────────
abstract class BulkEvent extends Equatable {
  const BulkEvent();
  @override
  List<Object?> get props => [];
}

class LoadBulkOrders extends BulkEvent {
  const LoadBulkOrders();
}

class MarkBulkDelivered extends BulkEvent {
  final String id;
  final bool hasCollectedBalance;
  final double? collectedAmount;

  const MarkBulkDelivered({
    required this.id,
    required this.hasCollectedBalance,
    this.collectedAmount,
  });

  @override
  List<Object?> get props => [id, hasCollectedBalance, collectedAmount];
}

// ─── State ───────────────────────────────────────────────────
class BulkState extends Equatable {
  final bool isLoading;
  final List<BulkOrderModel> orders;
  final String? deliveredId;

  const BulkState({
    this.isLoading = true,
    this.orders = const [],
    this.deliveredId,
  });

  BulkState copyWith({
    bool? isLoading,
    List<BulkOrderModel>? orders,
    String? deliveredId,
  }) {
    return BulkState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      deliveredId: deliveredId,
    );
  }

  @override
  List<Object?> get props => [isLoading, orders, deliveredId];
}

// ─── ViewModel (BLoC) ───────────────────────────────────────
class BulkViewModel extends Bloc<BulkEvent, BulkState> {
  final BulkRepository _repository;

  BulkViewModel({BulkRepository? repository})
      : _repository = repository ?? MockBulkRepository(),
        super(const BulkState()) {
    on<LoadBulkOrders>(_onLoad);
    on<MarkBulkDelivered>(_onDeliver);
  }

  Future<void> _onLoad(LoadBulkOrders event, Emitter<BulkState> emit) async {
    emit(state.copyWith(isLoading: true));
    final orders = await _repository.fetchBulkOrders();
    emit(state.copyWith(isLoading: false, orders: orders));
  }

  Future<void> _onDeliver(
      MarkBulkDelivered event, Emitter<BulkState> emit) async {
    final updated = await _repository.markDelivered(
      event.id,
      hasCollectedBalance: event.hasCollectedBalance,
      collectedAmount: event.collectedAmount,
    );
    final newList =
        state.orders.map((o) => o.id == event.id ? updated : o).toList();
    emit(state.copyWith(orders: newList, deliveredId: event.id));
    emit(state.copyWith(deliveredId: null));
  }
}
