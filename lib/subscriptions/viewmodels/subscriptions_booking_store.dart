import 'package:flutter/foundation.dart';
import '../models/booked_subscription_model.dart';

class SubscriptionsBookingStore extends ChangeNotifier {
  final List<BookedSubscription> _bookings = [];

  List<BookedSubscription> get bookings => List.unmodifiable(_bookings);

  bool get hasBookings => _bookings.isNotEmpty;

  void addBooking(BookedSubscription booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  void markBookingAsPaid(BookedSubscription booking) {
    final index = _bookings.indexOf(booking);
    if (index != -1) {
      _bookings[index] = BookedSubscription(
        planTitle: booking.planTitle,
        bookedAt: booking.bookedAt,
        configSummary: booking.configSummary,
        rateLines: booking.rateLines,
        monthlyMilkRupees: booking.monthlyMilkRupees,
        deliveryChargeRupees: booking.deliveryChargeRupees,
        monthlyBillRupees: booking.monthlyBillRupees,
        advanceRupees: booking.advanceRupees,
        balanceOnFullPaymentRupees: 0,
        isFullyPaid: true,
      );
      notifyListeners();
    }
  }

  void cancelBooking(BookedSubscription booking) {
    _bookings.remove(booking);
    notifyListeners();
  }

  void updateBooking(BookedSubscription oldB, BookedSubscription newB) {
    final index = _bookings.indexOf(oldB);
    if (index != -1) {
      _bookings[index] = newB;
      notifyListeners();
    }
  }
}
