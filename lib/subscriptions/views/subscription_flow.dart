import 'package:flutter/material.dart';
import '../models/subscription_quote_model.dart';
import 'subscription_confirmation_view.dart';

void openSubscriptionConfirmation(
  BuildContext context,
  SubscriptionQuote quote,
) {
  final navigator = Navigator.of(context);
  navigator.pop();
  navigator.push(
    MaterialPageRoute<void>(
      builder: (_) => SubscriptionConfirmationView(quote: quote),
    ),
  );
}
