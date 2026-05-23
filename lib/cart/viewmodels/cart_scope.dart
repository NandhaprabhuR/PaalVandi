import 'package:flutter/material.dart';
import 'cart_viewmodel.dart';

class CartScope extends InheritedNotifier<CartViewModel> {
  const CartScope({
    super.key,
    required CartViewModel store,
    required super.child,
  }) : super(notifier: store);

  static CartViewModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'CartScope not found');
    return scope!.notifier!;
  }

  static CartViewModel? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CartScope>()
        ?.notifier;
  }
}
