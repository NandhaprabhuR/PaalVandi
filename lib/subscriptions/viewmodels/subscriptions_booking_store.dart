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
}
