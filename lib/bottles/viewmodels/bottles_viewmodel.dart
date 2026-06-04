import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/bottle_collection_model.dart';
import '../repositories/bottle_repository.dart';

// ─── Events ──────────────────────────────────────────────────
abstract class BottlesEvent extends Equatable {
  const BottlesEvent();
  @override
  List<Object?> get props => [];
}

class LoadBottleCollections extends BottlesEvent {
  const LoadBottleCollections();
}

class MarkBottleCollected extends BottlesEvent {
  final String id;
  const MarkBottleCollected(this.id);
  @override
  List<Object?> get props => [id];
}

// ─── State ───────────────────────────────────────────────────
class BottlesState extends Equatable {
  final bool isLoading;
  final List<BottleCollectionModel> collections;
  final String? collectedId;

  const BottlesState({
    this.isLoading = true,
    this.collections = const [],
    this.collectedId,
  });

  BottlesState copyWith({
    bool? isLoading,
    List<BottleCollectionModel>? collections,
    String? collectedId,
  }) {
    return BottlesState(
      isLoading: isLoading ?? this.isLoading,
      collections: collections ?? this.collections,
      collectedId: collectedId,
    );
  }

  @override
  List<Object?> get props => [isLoading, collections, collectedId];
}

// ─── ViewModel (BLoC) ───────────────────────────────────────
class BottlesViewModel extends Bloc<BottlesEvent, BottlesState> {
  final BottleRepository _repository;

  BottlesViewModel({BottleRepository? repository})
      : _repository = repository ?? MockBottleRepository(),
        super(const BottlesState()) {
    on<LoadBottleCollections>(_onLoad);
    on<MarkBottleCollected>(_onCollect);
  }

  Future<void> _onLoad(
      LoadBottleCollections event, Emitter<BottlesState> emit) async {
    emit(state.copyWith(isLoading: true));
    final collections = await _repository.fetchPendingCollections();
    emit(state.copyWith(isLoading: false, collections: collections));
  }

  Future<void> _onCollect(
      MarkBottleCollected event, Emitter<BottlesState> emit) async {
    final updated = await _repository.markCollected(event.id);
    final newList = state.collections
        .map((b) => b.id == event.id ? updated : b)
        .toList();
    emit(state.copyWith(collections: newList, collectedId: event.id));
    emit(state.copyWith(collectedId: null));
  }
}
