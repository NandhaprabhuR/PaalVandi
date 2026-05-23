import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/subscription_plan_model.dart';
import '../viewmodels/subscriptions_scope.dart';
import '../widgets/subscription_call_dialog.dart';
import '../widgets/subscription_plan_card.dart';
import 'subscription_bottom_sheets.dart';
import 'your_subscriptions_view.dart';

class SubscriptionsTabView extends StatelessWidget {
  const SubscriptionsTabView({super.key});

  void _openSheet(BuildContext context, SubscriptionPlan plan) {
    switch (plan.title) {
      case 'Family Subscription':
        showFamilySubscriptionSheet(context);
        break;
      case 'Business Subscription':
        showBusinessSubscriptionSheet(context);
        break;
      case 'Event Subscription':
        showEventSubscriptionSheet(context);
        break;
      case 'Smart Subscription':
        showSmartSubscriptionSheet(context);
        break;
    }
  }

  void _openYourSubscriptions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const YourSubscriptionsView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = SubscriptionsScope.of(context);

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              'Subscriptions',
              style: CustomersLoginThemeView.brandTitleStyle.copyWith(
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => showSubscriptionCallDialog(context),
                tooltip: 'Call support',
                icon: const Icon(
                  Icons.phone_in_talk_outlined,
                  color: CustomersLoginThemeView.primaryBlue,
                ),
              ),
            ],
          ),
          body: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            itemCount: SubscriptionPlans.all.length +
                1 +
                (store.hasBookings ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Fresh daily milk delivered to your doorstep',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: CustomersLoginThemeView.textGrey,
                      height: 1.35,
                    ),
                  ),
                );
              }

              if (store.hasBookings && index == 1) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => _openYourSubscriptions(context),
                      icon: const Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: CustomersLoginThemeView.primaryBlue,
                      ),
                      label: Text(
                        'Your Subscriptions',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: CustomersLoginThemeView.primaryBlue,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CustomersLoginThemeView.primaryBlue,
                        side: const BorderSide(
                          color: CustomersLoginThemeView.primaryBlue,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final planIndex =
                  index - 1 - (store.hasBookings ? 1 : 0);
              final plan = SubscriptionPlans.all[planIndex];
              return SubscriptionPlanCard(
                plan: plan,
                onSubscribe: () => _openSheet(context, plan),
              );
            },
          ),
        );
      },
    );
  }
}
