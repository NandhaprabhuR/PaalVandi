import '../../subscriptions/models/booked_subscription_model.dart';

abstract class SubscriptionRepository {
  Future<List<BookedSubscription>> getBookings();
  Future<void> addBooking(BookedSubscription booking);
  Future<void> updateBooking(BookedSubscription oldB, BookedSubscription newB);
}

class MockSubscriptionRepository implements SubscriptionRepository {
  final List<BookedSubscription> _mockBookings = [];

  @override
  Future<List<BookedSubscription>> getBookings() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_mockBookings);
  }

  @override
  Future<void> addBooking(BookedSubscription booking) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _mockBookings.insert(0, booking);
  }

  @override
  Future<void> updateBooking(BookedSubscription oldB, BookedSubscription newB) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final index = _mockBookings.indexOf(oldB);
    if (index != -1) {
      _mockBookings[index] = newB;
    }
  }
}
