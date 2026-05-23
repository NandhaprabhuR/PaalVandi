import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/subscriptions_model.dart';

abstract class SubscriptionsEvent extends Equatable {
  const SubscriptionsEvent();
  @override
  List<Object> get props => [];
}

class LoadSubscriptions extends SubscriptionsEvent {}

abstract class SubscriptionsState extends Equatable {
  final SubscriptionsModel model;
  const SubscriptionsState(this.model);
  @override
  List<Object> get props => [model];
}

class SubscriptionsInitial extends SubscriptionsState {
  const SubscriptionsInitial(super.model);
}

class SubscriptionsLoaded extends SubscriptionsState {
  const SubscriptionsLoaded(super.model);
}

class SubscriptionsViewModel
    extends Bloc<SubscriptionsEvent, SubscriptionsState> {
  SubscriptionsViewModel()
      : super(const SubscriptionsInitial(SubscriptionsModel())) {
    on<LoadSubscriptions>((event, emit) async {
      emit(SubscriptionsLoaded(
        state.model.copyWith(
          activePlans: const ['Daily Milk', 'Weekly Curd'],
        ),
      ));
    });
  }
}
