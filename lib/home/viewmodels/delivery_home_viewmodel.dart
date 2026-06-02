import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/delivery_order_model.dart';

// Events
abstract class DeliveryHomeEvent extends Equatable {
  const DeliveryHomeEvent();
  @override
  List<Object?> get props => [];
}

class ToggleOnlineStatus extends DeliveryHomeEvent {
  const ToggleOnlineStatus();
}

class AcceptOrder extends DeliveryHomeEvent {
  final String orderId;
  const AcceptOrder(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class UpdateDeliveryStatus extends DeliveryHomeEvent {
  final String orderId;
  final String newStatus;
  const UpdateDeliveryStatus(this.orderId, this.newStatus);
  @override
  List<Object?> get props => [orderId, newStatus];
}

class VerifyOtpAndDeliver extends DeliveryHomeEvent {
  final String orderId;
  final String otp;
  const VerifyOtpAndDeliver(this.orderId, this.otp);
  @override
  List<Object?> get props => [orderId, otp];
}

// States
class DeliveryHomeState extends Equatable {
  final bool isOnline;
  final List<DeliveryOrderModel> assignedOrders;
  final DeliveryOrderModel? activeOrder;
  final double todayEarnings;
  final int todayDeliveriesCount;
  final double todayDistanceKm;
  final bool otpError;
  final bool deliveryCompleteSuccess;

  const DeliveryHomeState({
    this.isOnline = false,
    this.assignedOrders = const [],
    this.activeOrder,
    this.todayEarnings = 280.50,
    this.todayDeliveriesCount = 3,
    this.todayDistanceKm = 11.2,
    this.otpError = false,
    this.deliveryCompleteSuccess = false,
  });

  DeliveryHomeState copyWith({
    bool? isOnline,
    List<DeliveryOrderModel>? assignedOrders,
    DeliveryOrderModel? activeOrder,
    double? todayEarnings,
    int? todayDeliveriesCount,
    double? todayDistanceKm,
    bool? otpError,
    bool? deliveryCompleteSuccess,
  }) {
    return DeliveryHomeState(
      isOnline: isOnline ?? this.isOnline,
      assignedOrders: assignedOrders ?? this.assignedOrders,
      activeOrder: activeOrder, // Note: explicit assign to allow setting to null
      todayEarnings: todayEarnings ?? this.todayEarnings,
      todayDeliveriesCount: todayDeliveriesCount ?? this.todayDeliveriesCount,
      todayDistanceKm: todayDistanceKm ?? this.todayDistanceKm,
      otpError: otpError ?? this.otpError,
      deliveryCompleteSuccess: deliveryCompleteSuccess ?? this.deliveryCompleteSuccess,
    );
  }

  @override
  List<Object?> get props => [
        isOnline,
        assignedOrders,
        activeOrder,
        todayEarnings,
        todayDeliveriesCount,
        todayDistanceKm,
        otpError,
        deliveryCompleteSuccess,
      ];
}

// ViewModel (BLoC)
class DeliveryHomeViewModel extends Bloc<DeliveryHomeEvent, DeliveryHomeState> {
  DeliveryHomeViewModel() : super(const DeliveryHomeState()) {
    
    on<ToggleOnlineStatus>((event, emit) {
      final nextOnline = !state.isOnline;
      if (nextOnline) {
        // Load premium mock orders with 5-character alphanumeric mixtures
        final mockOrders = [
          const DeliveryOrderModel(
            orderId: 'M9X2K',
            customerName: 'Nandha Prabhu',
            customerPhone: '9876543210',
            address: '14, Cross Cut Road, Gandhipuram',
            landmark: 'Near Lakshmi Complex',
            totalAmount: 180.00,
            advancePaid: 0.00,
            isCod: true,
            items: [
              DeliveryProductItem(productName: 'Fresh Cow Milk (1L)', quantity: 2),
              DeliveryProductItem(productName: 'Premium Buttermilk (500ml)', quantity: 1),
            ],
            deliveryStatus: 'Assigned',
            orderType: 'Order',
            deliveryDate: 'Today',
            timeSlot: '6:00 AM - 8:00 AM',
          ),
          const DeliveryOrderModel(
            orderId: 'B7R8W',
            customerName: 'Anjali Sharma',
            customerPhone: '9443210987',
            address: 'SF-4, Green Meadows Apartments, Saravanampatti',
            landmark: 'Opposite KGISL Tech Park',
            totalAmount: 1450.00,
            advancePaid: 350.00,
            isCod: true, // COD but has advance paid, so showing balance
            items: [
              DeliveryProductItem(productName: 'Fresh Cow Curd (500ml)', quantity: 8),
              DeliveryProductItem(productName: 'Premium Cow Milk (1L)', quantity: 10),
            ],
            deliveryStatus: 'Assigned',
            orderType: 'Bulk Booking',
            deliveryDate: 'Today',
            timeSlot: '7:00 AM - 9:00 AM',
          ),
          const DeliveryOrderModel(
            orderId: 'S4Y8P',
            customerName: 'Rajesh Kumar',
            customerPhone: '8870123456',
            address: '102, Shanthi Colony, Peelamedu',
            landmark: 'Behind PSG Tech Campus',
            totalAmount: 90.00,
            advancePaid: 90.00,
            isCod: false, // Fully paid online
            items: [
              DeliveryProductItem(productName: 'Fresh Cow Milk (500ml)', quantity: 2),
            ],
            deliveryStatus: 'Assigned',
            orderType: 'Subscription',
            deliveryDate: 'Today',
            timeSlot: '6:00 AM - 8:00 AM',
          ),
        ];
        emit(state.copyWith(
          isOnline: true,
          assignedOrders: mockOrders,
        ));
      } else {
        emit(state.copyWith(
          isOnline: false,
          assignedOrders: [],
          activeOrder: null,
        ));
      }
    });

    on<AcceptOrder>((event, emit) {
      final acceptedOrder = state.assignedOrders.firstWhere(
        (o) => o.orderId == event.orderId,
      );
      
      final updatedList = state.assignedOrders
          .where((o) => o.orderId != event.orderId)
          .toList();

      final active = acceptedOrder.copyWith(deliveryStatus: 'Accepted');

      emit(state.copyWith(
        assignedOrders: updatedList,
        activeOrder: active,
      ));
    });

    on<UpdateDeliveryStatus>((event, emit) {
      if (state.activeOrder == null || state.activeOrder!.orderId != event.orderId) return;

      final updated = state.activeOrder!.copyWith(deliveryStatus: event.newStatus);
      emit(state.copyWith(activeOrder: updated));
    });

    on<VerifyOtpAndDeliver>((event, emit) async {
      if (state.activeOrder == null || state.activeOrder!.orderId != event.orderId) return;

      // Mock OTP is always 123456 for easy verification testing
      if (event.otp != '123456') {
        emit(state.copyWith(otpError: true));
        return;
      }

      emit(state.copyWith(otpError: false));
      // Simulate quick premium processing
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Calculate earnings (₹45 per standard order, ₹120 for bulk booking, ₹30 for subscription)
      double tripPay = 45.00;
      if (state.activeOrder!.orderType == 'Bulk Booking') {
        tripPay = 120.00;
      } else if (state.activeOrder!.orderType == 'Subscription') {
        tripPay = 30.00;
      }

      emit(state.copyWith(
        todayEarnings: state.todayEarnings + tripPay,
        todayDeliveriesCount: state.todayDeliveriesCount + 1,
        todayDistanceKm: state.todayDistanceKm + 3.2,
        deliveryCompleteSuccess: true,
        activeOrder: null, // order completed, cleared active
      ));
    });
  }
}
