import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customers_home_model.dart';

// Events
abstract class CustomersHomeEvent extends Equatable {
  const CustomersHomeEvent();
  @override
  List<Object> get props => [];
}

class LoadHomeData extends CustomersHomeEvent {}

class LogoutRequested extends CustomersHomeEvent {}

// States
abstract class CustomersHomeState extends Equatable {
  final CustomersHomeModel model;
  const CustomersHomeState(this.model);
  @override
  List<Object> get props => [model];
}

class HomeInitial extends CustomersHomeState {
  const HomeInitial(super.model);
}

class HomeLoading extends CustomersHomeState {
  const HomeLoading(super.model);
}

class HomeLoaded extends CustomersHomeState {
  const HomeLoaded(super.model);
}

class HomeError extends CustomersHomeState {
  final String message;
  const HomeError(super.model, this.message);
  @override
  List<Object> get props => [model, message];
}

class HomeLoggedOut extends CustomersHomeState {
  const HomeLoggedOut(super.model);
}

// ViewModel (BLoC)
class CustomersHomeViewModel extends Bloc<CustomersHomeEvent, CustomersHomeState> {
  // ignore: unused_field
  final dynamic _supabase;

  CustomersHomeViewModel(this._supabase) : super(const HomeInitial(CustomersHomeModel())) {
    on<LoadHomeData>((event, emit) async {
      emit(HomeLoading(state.model.copyWith(isLoading: true)));
      try {
        // MOCK SUPABASE CALL
        await Future.delayed(const Duration(milliseconds: 500));
        emit(HomeLoaded(state.model.copyWith(
          isLoading: false,
          availableProducts: ['Milk', 'Curd', 'Moor'],
        )));
      } catch (e) {
        emit(HomeError(state.model.copyWith(isLoading: false), e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      // MOCK SUPABASE CALL
      await Future.delayed(const Duration(milliseconds: 500));
      emit(HomeLoggedOut(state.model));
    });
  }
}
