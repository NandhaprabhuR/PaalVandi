import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cart/viewmodels/cart_scope.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/payment_model.dart';
import '../viewmodels/payment_viewmodel.dart';
import 'order_tracking_view.dart';
import 'payment_success_view.dart';

class PaymentSelectionView extends StatelessWidget {
  const PaymentSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    return BlocProvider(
      create: (_) => PaymentViewModel(cart),
      child: const _PaymentSelectionBody(),
    );
  }
}

class _PaymentSelectionBody extends StatelessWidget {
  const _PaymentSelectionBody();

  void _openSuccessThenTracking(BuildContext context, bool paidOnline) {
    final cart = CartScope.of(context);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (successContext) => PaymentSuccessView(
          paidOnline: paidOnline,
          onFinished: () {
            final orderId = cart.activeTrackedOrder?.orderId;
            if (orderId == null) return;
            Navigator.of(successContext).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => CartScope(
                  store: cart,
                  child: OrderTrackingView(orderId: orderId),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentViewModel, PaymentState>(
      listener: (context, state) {
        if (state is PaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
              content: Text(
                state.error,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          );
        } else if (state is PaymentSuccess) {
          final paidOnline =
              state.model.selectedMethod == PaalvandiPaymentMethod.payNowUpi;
          _openSuccessThenTracking(context, paidOnline);
        }
      },
      builder: (context, state) {
        final model = state.model;
        final processing = state is PaymentProcessing;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: CustomersLoginThemeView.primaryBlue,
              ),
              onPressed: processing ? null : () => Navigator.pop(context),
            ),
            title: Text(
              'Payment Method',
              style: CustomersLoginThemeView.brandTitleStyle.copyWith(
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose how you would like to complete your order',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: CustomersLoginThemeView.textGrey,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _OrderSummaryCard(lines: model.summaryLines, total: model.totalRupees),
                    const SizedBox(height: 22),
                    Text(
                      'Select Payment Method',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PaymentMethodCard(
                      emoji: '💳',
                      title: 'Pay Now (UPI)',
                      description: 'Pay instantly using:',
                      bullets: const [
                        'Google Pay',
                        'PhonePe',
                        'Paytm',
                        'BHIM UPI',
                      ],
                      footer: 'Secure payment with instant confirmation',
                      trailingIcons: const [
                        Icons.account_balance_wallet_outlined,
                        Icons.payments_outlined,
                      ],
                      selected: model.selectedMethod == PaalvandiPaymentMethod.payNowUpi,
                      onTap: () => context.read<PaymentViewModel>().add(
                            const SelectPaymentMethod(PaalvandiPaymentMethod.payNowUpi),
                          ),
                      expandedChild: _UpiAppsSection(
                        selected: model.selectedUpiApp,
                        onSelect: (app) =>
                            context.read<PaymentViewModel>().add(SelectUpiApp(app)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PaymentMethodCard(
                      emoji: '🚚',
                      title: 'Pay at Delivery',
                      description: 'Scan QR and pay when delivery arrives',
                      bullets: const [],
                      footer: 'Pay using any UPI app at doorstep',
                      trailingIcons: const [Icons.qr_code_2_outlined],
                      selected: model.selectedMethod == PaalvandiPaymentMethod.payAtDelivery,
                      onTap: () => context.read<PaymentViewModel>().add(
                            const SelectPaymentMethod(
                              PaalvandiPaymentMethod.payAtDelivery,
                            ),
                          ),
                      expandedChild: _PayAtDeliverySection(),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: processing
                            ? null
                            : () => context
                                .read<PaymentViewModel>()
                                .add(const ProcessPayment()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomersLoginThemeView.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: processing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Continue',
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final List<OrderSummaryLine> lines;
  final int total;

  const _OrderSummaryCard({required this.lines, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: CustomersLoginThemeView.cardDecoration,
      child: Column(
        children: [
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      line.label,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                  ),
                  Text(
                    '₹${line.amountRupees}',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
              Text(
                '₹$total',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.priceAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final List<String> bullets;
  final String footer;
  final List<IconData> trailingIcons;
  final bool selected;
  final VoidCallback onTap;
  final Widget expandedChild;

  const _PaymentMethodCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.bullets,
    required this.footer,
    required this.trailingIcons,
    required this.selected,
    required this.onTap,
    required this.expandedChild,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.01 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? CustomersLoginThemeView.primaryBlue
                : CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.25),
            width: selected ? 2 : 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: CustomersLoginThemeView.primaryBlue
                        .withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: CustomersLoginThemeView.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: CustomersLoginThemeView.textGrey,
                              height: 1.3,
                            ),
                          ),
                          if (bullets.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            ...bullets.map(
                              (b) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  '• $b',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    color: CustomersLoginThemeView.quantityAccent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            footer,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? CustomersLoginThemeView.primaryBlue
                              : CustomersLoginThemeView.textGrey,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: trailingIcons
                              .map(
                                (icon) => Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Icon(
                                    icon,
                                    size: 20,
                                    color: CustomersLoginThemeView.primaryBlue
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: expandedChild,
              crossFadeState:
                  selected ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }
}

class _UpiAppsSection extends StatelessWidget {
  final UpiAppOption selected;
  final ValueChanged<UpiAppOption> onSelect;

  const _UpiAppsSection({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            'Available Apps',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: CustomersLoginThemeView.textDark,
            ),
          ),
          const SizedBox(height: 8),
          ...UpiAppOption.values.map(
            (app) => _RadioTile(
              label: app.label,
              selected: app == selected,
              onTap: () => onSelect(app),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayAtDeliverySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            'Payment Information',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: CustomersLoginThemeView.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please scan the delivery QR code and complete payment after receiving your order.',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: CustomersLoginThemeView.textGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _deliveryInfoRow('🚚', 'Estimated Delivery:', 'Within 20 minutes'),
          const SizedBox(height: 8),
          _deliveryInfoRow('⏰', 'Delivery Hours:', 'Morning 5:00 AM to Night 9:00 PM'),
        ],
      ),
    );
  }

  Widget _deliveryInfoRow(String emoji, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: CustomersLoginThemeView.textGrey,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RadioTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected
                  ? CustomersLoginThemeView.primaryBlue
                  : CustomersLoginThemeView.textGrey,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? CustomersLoginThemeView.primaryBlue
                    : CustomersLoginThemeView.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
