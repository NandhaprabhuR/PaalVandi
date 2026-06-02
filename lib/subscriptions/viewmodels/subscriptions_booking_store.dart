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
      _bookings[index] = booking.copyWith(
        balanceOnFullPaymentRupees: 0,
        isFullyPaid: true,
      );
      notifyListeners();
    }
  }

  void pauseBooking(BookedSubscription booking, DateTime start, DateTime end) {
    final index = _bookings.indexOf(booking);
    if (index != -1) {
      _bookings[index] = booking.copyWith(
        status: 'Paused',
        pauseStartDate: start,
        pauseEndDate: end,
      );
      notifyListeners();
    }
  }

  void resumeBooking(BookedSubscription booking) {
    final index = _bookings.indexOf(booking);
    if (index != -1) {
      _bookings[index] = booking.copyWith(
        status: 'Active',
        pauseStartDate: null,
        pauseEndDate: null,
      );
      notifyListeners();
    }
  }

  void cancelBooking(BookedSubscription booking) {
    final index = _bookings.indexOf(booking);
    if (index != -1) {
      _bookings[index] = booking.copyWith(
        status: 'Cancelled',
      );
      notifyListeners();
    }
  }

  void updateBooking(BookedSubscription oldB, BookedSubscription newB) {
    final index = _bookings.indexOf(oldB);
    if (index != -1) {
      _bookings[index] = newB;
      notifyListeners();
    }
  }
}
