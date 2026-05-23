import 'package:flutter/material.dart';
import 'subscriptions_booking_store.dart';

class SubscriptionsScope extends InheritedNotifier<SubscriptionsBookingStore> {
  const SubscriptionsScope({
    super.key,
    required SubscriptionsBookingStore store,
    required super.child,
  }) : super(notifier: store);

  static SubscriptionsBookingStore of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<SubscriptionsScope>();
    assert(scope != null, 'SubscriptionsScope not found');
    return scope!.notifier!;
  }
}
