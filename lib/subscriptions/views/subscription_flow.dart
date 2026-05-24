import 'package:flutter/material.dart';
import '../models/subscription_quote_model.dart';
import '../viewmodels/subscriptions_scope.dart';
import 'subscription_confirmation_view.dart';

void openSubscriptionConfirmation(
  BuildContext context,
  SubscriptionQuote quote,
) {
  final store = SubscriptionsScope.of(context);
  final navigator = Navigator.of(context);
  navigator.pop();
  navigator.push(
    MaterialPageRoute<void>(
      builder: (_) => SubscriptionsScope(
        store: store,
        child: SubscriptionConfirmationView(quote: quote),
      ),
    ),
  );
}
