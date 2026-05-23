import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/subscription_quote_model.dart';
import '../viewmodels/subscriptions_scope.dart';
import '../widgets/subscription_sheet_widgets.dart';

class SubscriptionConfirmationView extends StatelessWidget {
  final SubscriptionQuote quote;

  const SubscriptionConfirmationView({super.key, required this.quote});

  void _payAdvance(BuildContext context) {
    SubscriptionsScope.of(context).addBooking(quote.toBooking());
    Navigator.of(context).pop();
    showSubscriptionContinueSnackBar(
      context,
      '${quote.planTitle} confirmed',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: quote.backgroundColor,
      appBar: AppBar(
        backgroundColor: quote.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(
          color: CustomersLoginThemeView.primaryBlue,
        ),
        title: Text(
          'Subscription Bill',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    quote.planTitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: CustomersLoginThemeView.sectionHeadingRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _infoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: quote.configSummary
                          .map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                line,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: CustomersLoginThemeView.textDark,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Monthly rates',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _infoCard(
                    child: Column(
                      children: [
                        for (final line in quote.rateLines)
                          _billRow(line.label, line.amountRupees,
                              bold: line.label.contains('total') ||
                                  line.label.contains('Total')),
                        const Divider(height: 20),
                        _billRow(
                          'Delivery charge',
                          quote.deliveryChargeRupees,
                          accent: true,
                        ),
                        const SizedBox(height: 6),
                        _billRow(
                          'Monthly bill amount',
                          quote.monthlyBillRupees,
                          bold: true,
                          large: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _noteBanner(
                    icon: Icons.local_shipping_outlined,
                    text:
                        'No delivery charge for this subscription payment.',
                    color: CustomersLoginThemeView.primaryBlue,
                  ),
                  const SizedBox(height: 8),
                  _noteBanner(
                    icon: Icons.payments_outlined,
                    text:
                        'Pay ₹${quote.advanceRupees} advance now to confirm your subscription. This amount will be adjusted and deducted from your full monthly payment.',
                    color: CustomersLoginThemeView.sectionHeadingRed,
                  ),
                  const SizedBox(height: 8),
                  _infoCard(
                    child: Column(
                      children: [
                        _billRow('Advance payable now', quote.advanceRupees,
                            bold: true),
                        _billRow(
                          'Balance on full payment',
                          quote.balanceOnFullPaymentRupees,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: quote.backgroundColor,
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _payAdvance(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomersLoginThemeView.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Pay ₹${quote.advanceRupees} advance & confirm',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }

  Widget _billRow(
    String label,
    int amount, {
    bool bold = false,
    bool large = false,
    bool accent = false,
  }) {
    final display = label == 'Estimated days'
        ? '$amount days'
        : '₹$amount';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: large ? 15 : 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                color: accent
                    ? CustomersLoginThemeView.quantityAccent
                    : CustomersLoginThemeView.textDark,
              ),
            ),
          ),
          Text(
            display,
            style: GoogleFonts.montserrat(
              fontSize: large ? 18 : 14,
              fontWeight: FontWeight.w800,
              color: large
                  ? CustomersLoginThemeView.priceAccent
                  : CustomersLoginThemeView.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteBanner({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CustomersLoginThemeView.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
