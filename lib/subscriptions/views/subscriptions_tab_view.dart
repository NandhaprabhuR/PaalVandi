import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/subscription_plan_model.dart';
import '../viewmodels/subscriptions_scope.dart';
import '../widgets/subscription_call_dialog.dart';
import '../widgets/subscription_plan_card.dart';
import 'subscription_bottom_sheets.dart';
import 'your_subscriptions_view.dart';
import '../../core/widgets/paalvandi_confirm_dialog.dart';

import '../../core/widgets/shimmer_loading.dart';

class SubscriptionsTabView extends StatefulWidget {
  const SubscriptionsTabView({super.key});

  @override
  State<SubscriptionsTabView> createState() => _SubscriptionsTabViewState();
}

class _SubscriptionsTabViewState extends State<SubscriptionsTabView> {
  bool _isLocalLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate high-fidelity skeleton loading delay of 1 second
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLocalLoading = false;
        });
      }
    });
  }

  void _openSheet(BuildContext context, SubscriptionPlan plan) {
    final store = SubscriptionsScope.of(context);
    if (store.bookings.any((b) => b.planTitle == plan.title)) {
      showPaalvandiConfirmDialog(
        context,
        title: 'Active Subscription Found',
        message: 'You already have an active subscription for ${plan.title}. Would you like to view your active subscriptions?',
        noLabel: 'Cancel',
        yesLabel: 'View',
      ).then((view) {
        if (view == true && context.mounted) {
          _openYourSubscriptions(context);
        }
      });
      return;
    }

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
    final store = SubscriptionsScope.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SubscriptionsScope(
          store: store,
          child: const YourSubscriptionsView(),
        ),
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
          backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
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
          body: _isLocalLoading
              ? _buildSubscriptionsSkeleton(context)
              : ListView.builder(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                final hasUnpaid = store.bookings.any((b) => !b.isFullyPaid);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => _openYourSubscriptions(context),
                      icon: hasUnpaid
                          ? const Badge(
                              backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 20,
                                color: CustomersLoginThemeView.primaryBlue,
                              ),
                            )
                          : const Icon(
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
              final isActivePlan = store.bookings.any((b) => b.planTitle == plan.title);
              return SubscriptionPlanCard(
                plan: plan,
                isActive: isActivePlan,
                onSubscribe: () => _openSheet(context, plan),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionsSkeleton(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Align(
            alignment: Alignment.center,
            child: ShimmerSkeleton(
              width: 240,
              height: 14,
              borderRadius: 3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(2, (index) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.black12, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerSkeleton(width: 140, height: 16, borderRadius: 3),
                    ShimmerSkeleton(width: 40, height: 16, borderRadius: 8),
                  ],
                ),
                const SizedBox(height: 10),
                const ShimmerSkeleton(width: double.infinity, height: 12, borderRadius: 3),
                const SizedBox(height: 6),
                const ShimmerSkeleton(width: 200, height: 12, borderRadius: 3),
                const SizedBox(height: 10),
                const ShimmerSkeleton(width: 120, height: 11, borderRadius: 3),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    ShimmerSkeleton(width: 90, height: 22, borderRadius: 12),
                    SizedBox(width: 6),
                    ShimmerSkeleton(width: 90, height: 22, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 18),
                const ShimmerSkeleton(width: double.infinity, height: 36, borderRadius: 10),
              ],
            ),
          );
        }),
      ],
    );
  }
}
