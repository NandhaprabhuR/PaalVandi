import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/subscription_plan_model.dart';
import '../viewmodels/subscriptions_scope.dart';

class YourSubscriptionsView extends StatelessWidget {
  const YourSubscriptionsView({super.key});

  SubscriptionPlan? _planFor(String title) {
    for (final p in SubscriptionPlans.all) {
      if (p.title == title) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final store = SubscriptionsScope.of(context);

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final bookings = store.bookings;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(
              color: CustomersLoginThemeView.primaryBlue,
            ),
            title: Text(
              'Your Subscriptions',
              style: CustomersLoginThemeView.brandTitleStyle.copyWith(
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
          ),
          body: bookings.isEmpty
              ? Center(
                  child: Text(
                    'No subscription history yet',
                    style: CustomersLoginThemeView.subtitleStyle,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: bookings.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final plan = _planFor(booking.planTitle);
                    final tint = plan?.cardTint ??
                        CustomersLoginThemeView.primaryBlue
                            .withValues(alpha: 0.08);
                    final dateStr = DateFormat('dd MMM yyyy · hh:mm a')
                        .format(booking.bookedAt);

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CustomersLoginThemeView.primaryBlue
                              .withValues(alpha: 0.22),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (plan != null)
                                Icon(
                                  plan.icon,
                                  color: CustomersLoginThemeView.primaryBlue,
                                  size: 26,
                                ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  booking.planTitle,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: CustomersLoginThemeView
                                        .sectionHeadingRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confirmed · $dateStr',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: CustomersLoginThemeView.textGrey,
                            ),
                          ),
                          if (booking.configSummary.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            ...booking.configSummary.map(
                              (line) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  line,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: CustomersLoginThemeView.textDark,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (booking.rateLines.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Rates',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: CustomersLoginThemeView.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...booking.rateLines.map(
                              (line) => Text(
                                line,
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: CustomersLoginThemeView.textGrey,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                _historyRow(
                                  'Monthly bill',
                                  '₹${booking.monthlyBillRupees}',
                                  bold: true,
                                ),
                                _historyRow(
                                  'Delivery charge',
                                  '₹${booking.deliveryChargeRupees} (free)',
                                ),
                                _historyRow(
                                  'Advance paid',
                                  '₹${booking.advanceRupees}',
                                ),
                                _historyRow(
                                  'Balance on full payment',
                                  '₹${booking.balanceOnFullPaymentRupees}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Advance adjusted against full monthly payment · No delivery charge',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _historyRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: CustomersLoginThemeView.textDark,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: CustomersLoginThemeView.priceAccent,
            ),
          ),
        ],
      ),
    );
  }
}
