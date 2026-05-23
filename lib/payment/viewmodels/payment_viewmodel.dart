import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';
import '../models/payment_model.dart';
import '../services/upi_payment_service.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object?> get props => [];
}

class SelectPaymentMethod extends PaymentEvent {
  final PaalvandiPaymentMethod method;
  const SelectPaymentMethod(this.method);
  @override
  List<Object?> get props => [method];
}

class SelectUpiApp extends PaymentEvent {
  final UpiAppOption app;
  const SelectUpiApp(this.app);
  @override
  List<Object?> get props => [app];
}

class ProcessPayment extends PaymentEvent {
  const ProcessPayment();
}

abstract class PaymentState extends Equatable {
  final PaymentModel model;
  const PaymentState(this.model);
  @override
  List<Object?> get props => [model];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial(super.model);
}

class PaymentProcessing extends PaymentState {
  const PaymentProcessing(super.model);
}

class PaymentSuccess extends PaymentState {
  const PaymentSuccess(super.model);
}

class PaymentFailure extends PaymentState {
  final String error;
  const PaymentFailure(super.model, this.error);
  @override
  List<Object?> get props => [model, error];
}

class PaymentViewModel extends Bloc<PaymentEvent, PaymentState> {
  final CartViewModel cart;

  PaymentViewModel(this.cart) : super(PaymentInitial(PaymentModel.fromCart(cart))) {
    on<SelectPaymentMethod>((event, emit) {
      emit(
        PaymentInitial(
          state.model.copyWith(
            selectedMethod: event.method,
            clearError: true,
          ),
        ),
      );
    });

    on<SelectUpiApp>((event, emit) {
      emit(
        PaymentInitial(
          state.model.copyWith(
            selectedUpiApp: event.app,
            clearError: true,
          ),
        ),
      );
    });

    on<ProcessPayment>(_onProcessPayment);
  }

  Future<void> _onProcessPayment(
    ProcessPayment event,
    Emitter<PaymentState> emit,
  ) async {
    final model = state.model;

    if (model.selectedMethod == PaalvandiPaymentMethod.none) {
      emit(PaymentFailure(model, 'Please select a payment method'));
      return;
    }

    if (cart.items.isEmpty) {
      emit(PaymentFailure(model, 'Your cart is empty'));
      return;
    }

    emit(PaymentProcessing(model.copyWith(status: PaymentFlowStatus.processing)));

    try {
      if (model.selectedMethod == PaalvandiPaymentMethod.payNowUpi) {
        final launched = await UpiPaymentService.launchUpiPayment(
          app: model.selectedUpiApp,
          amountRupees: model.totalRupees,
        );
        if (!launched) {
          await Future<void>.delayed(const Duration(milliseconds: 800));
        } else {
          await Future<void>.delayed(const Duration(seconds: 2));
        }
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 900));
      }

      cart.completeOrder(
        paymentMethod: model.selectedMethod,
        upiApp: model.selectedMethod == PaalvandiPaymentMethod.payNowUpi
            ? model.selectedUpiApp
            : null,
      );

      emit(
        PaymentSuccess(
          model.copyWith(status: PaymentFlowStatus.success, clearError: true),
        ),
      );
    } catch (e) {
      emit(
        PaymentFailure(
          model.copyWith(status: PaymentFlowStatus.failure),
          'Payment could not be completed. Please try again.',
        ),
      );
    }
  }
}
