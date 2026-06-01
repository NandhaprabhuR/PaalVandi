import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cart/viewmodels/cart_scope.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../models/payment_model.dart';
import '../viewmodels/payment_viewmodel.dart';
import 'order_tracking_view.dart';
import 'payment_success_view.dart';
import '../../profile/viewmodels/customers_profile_viewmodel.dart';
import '../../profile/views/add_address_view.dart';

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

  void _showAddressPickerBottomSheet(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    // List of added mock addresses
    final List<Map<String, String>> mockAddedAddresses = [
      {
        'label': 'Home',
        'houseNo': 'Flat 402, Block B',
        'apartmentName': 'Skyline Apartments',
        'street': 'Vadavalli, Coimbatore',
        'deliveryPreference': 'Deliver Here (Primary)',
      },
      {
        'label': 'Office',
        'houseNo': 'Suite 101, 3rd Floor',
        'apartmentName': 'Tidel Park',
        'street': 'Avinashi Road, Coimbatore',
        'deliveryPreference': 'Deliver Here (Primary)',
      },
      {
        'label': 'Parent\'s House',
        'houseNo': 'No. 24, Gandhi Street',
        'apartmentName': '',
        'street': 'RS Puram, Coimbatore',
        'deliveryPreference': 'Deliver to Both Places',
      },
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(scaleF(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Primary Address',
                      style: CustomersLoginThemeView.brandTitleStyle.copyWith(
                        fontSize: fs(22),
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                SizedBox(height: scaleF(12)),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: mockAddedAddresses.length,
                    itemBuilder: (context, index) {
                      final addr = mockAddedAddresses[index];
                      final displayStr = [
                        if (addr['houseNo']!.isNotEmpty) addr['houseNo']!,
                        if (addr['apartmentName']!.isNotEmpty) addr['apartmentName']!,
                        addr['street']!,
                      ].join(', ');

                      return Card(
                        margin: EdgeInsets.only(bottom: scaleF(10)),
                        elevation: 0,
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(4)),
                          leading: Text(
                            addr['label'] == 'Home' ? '🏠' : (addr['label'] == 'Office' ? '🏢' : '📍'),
                            style: const TextStyle(fontSize: 22),
                          ),
                          title: Text(
                            addr['label']!,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(14),
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.textDark,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayStr,
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(11),
                                  fontWeight: FontWeight.w500,
                                  color: CustomersLoginThemeView.textGrey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Preference: ${addr['deliveryPreference']}',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(10),
                                  fontWeight: FontWeight.bold,
                                  color: CustomersLoginThemeView.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Update dynamic state in BLoC globally
                            context.read<CustomersProfileViewModel>().add(
                                  ProfileFieldChanged(
                                    houseNo: addr['houseNo'],
                                    apartmentName: addr['apartmentName'],
                                    street: addr['street'],
                                    deliveryPreference: addr['deliveryPreference'],
                                  ),
                                );
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: scaleF(12)),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddAddressView(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white, size: 18),
                  label: Text(
                    'Add New Address',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomersLoginThemeView.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return BlocConsumer<PaymentViewModel, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
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
              icon: Icon(
                Icons.arrow_back,
                color: CustomersLoginThemeView.primaryBlue,
                size: scaleF(24).clamp(20.0, 28.0),
              ),
              onPressed: processing ? null : () => Navigator.pop(context),
            ),
            title: Text(
              'Payment Method',
              style: CustomersLoginThemeView.brandTitleStyle.copyWith(
                fontSize: fs(22),
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPadding, scaleF(4), hPadding, scaleF(100)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose how you would like to complete your order',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(13),
                        fontWeight: FontWeight.w500,
                        color: CustomersLoginThemeView.textGrey,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: scaleF(16)),

                    // Delivering Here active address card with Pencil edit button
                    BlocBuilder<CustomersProfileViewModel, CustomersProfileState>(
                      builder: (context, profileState) {
                        final model = profileState.model;
                        String displayAddress = 'Coimbatore (Primary)';
                        if (model.street.isNotEmpty) {
                          final parts = [
                            if (model.houseNo.isNotEmpty) model.houseNo,
                            if (model.apartmentName.isNotEmpty) model.apartmentName,
                            model.street,
                          ];
                          displayAddress = '${parts.join(', ')} (${model.deliveryPreference})';
                        }

                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: scaleF(14), vertical: scaleF(10)),
                          decoration: BoxDecoration(
                            color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: CustomersLoginThemeView.primaryBlue,
                                size: scaleF(22),
                              ),
                              SizedBox(width: scaleF(12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Delivering Here',
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(13),
                                        fontWeight: FontWeight.bold,
                                        color: CustomersLoginThemeView.primaryBlue,
                                      ),
                                    ),
                                    SizedBox(height: scaleF(4)),
                                    Text(
                                      displayAddress,
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(12),
                                        fontWeight: FontWeight.w600,
                                        color: CustomersLoginThemeView.textDark,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: CustomersLoginThemeView.primaryBlue,
                                  size: scaleF(20),
                                ),
                                onPressed: () => _showAddressPickerBottomSheet(context),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: scaleF(16)),
                    _OrderSummaryCard(lines: model.summaryLines, total: model.totalRupees, fs: fs, scaleF: scaleF),
                    SizedBox(height: scaleF(22)),
                    Text(
                      'Select Payment Method',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(16),
                        fontWeight: FontWeight.w800,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(12)),
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
                      fs: fs,
                      scaleF: scaleF,
                      expandedChild: _UpiAppsSection(
                        selected: model.selectedUpiApp,
                        onSelect: (app) =>
                            context.read<PaymentViewModel>().add(SelectUpiApp(app)),
                        fs: fs,
                        scaleF: scaleF,
                      ),
                    ),
                    SizedBox(height: scaleF(12)),
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
                      fs: fs,
                      scaleF: scaleF,
                      expandedChild: _PayAtDeliverySection(fs: fs, scaleF: scaleF),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state is PaymentFailure)
                      Container(
                        width: double.infinity,
                        color: CustomersLoginThemeView.sectionHeadingRed,
                        padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(8)),
                        child: Text(
                          state.error,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: fs(12),
                          ),
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.fromLTRB(hPadding, scaleF(10), hPadding, scaleF(12)),
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
                          height: scaleF(48).clamp(42.0, 54.0),
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
                                ? SizedBox(
                                    width: scaleF(22),
                                    height: scaleF(22),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Continue',
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(15),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
  final double Function(double) fs;
  final double Function(double) scaleF;

  const _OrderSummaryCard({
    required this.lines,
    required this.total,
    required this.fs,
    required this.scaleF,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(scaleF(16)),
      decoration: CustomersLoginThemeView.cardDecoration,
      child: Column(
        children: [
          ...lines.map(
            (line) => Padding(
              padding: EdgeInsets.only(bottom: scaleF(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      line.label,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(13),
                        fontWeight: FontWeight.w500,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                  ),
                  Text(
                    '₹${line.amountRupees}',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(13),
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
                  fontSize: fs(16),
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
              Text(
                '₹$total',
                style: GoogleFonts.montserrat(
                  fontSize: fs(18),
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
  final double Function(double) fs;
  final double Function(double) scaleF;

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
    required this.fs,
    required this.scaleF,
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
            color: Colors.black,
            width: selected ? 2.0 : 1.0,
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
                padding: EdgeInsets.all(scaleF(14)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emoji, style: TextStyle(fontSize: fs(26))),
                    SizedBox(width: scaleF(10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(15),
                              fontWeight: FontWeight.w800,
                              color: CustomersLoginThemeView.textDark,
                            ),
                          ),
                          SizedBox(height: scaleF(6)),
                          Text(
                            description,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              color: CustomersLoginThemeView.textGrey,
                              height: 1.3,
                            ),
                          ),
                          if (bullets.isNotEmpty) ...[
                            SizedBox(height: scaleF(6)),
                            ...bullets.map(
                              (b) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  '• $b',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(11),
                                    color: CustomersLoginThemeView.quantityAccent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: scaleF(6)),
                          Text(
                            footer,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(10),
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
                          size: scaleF(24).clamp(20.0, 28.0),
                        ),
                        SizedBox(height: scaleF(8)),
                        Row(
                          children: trailingIcons
                              .map(
                                (icon) => Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Icon(
                                    icon,
                                    size: scaleF(20).clamp(16.0, 24.0),
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
  final double Function(double) fs;
  final double Function(double) scaleF;

  const _UpiAppsSection({
    required this.selected,
    required this.onSelect,
    required this.fs,
    required this.scaleF,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(scaleF(14), 0, scaleF(14), scaleF(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          SizedBox(height: scaleF(12)),
          Text(
            'Available Apps',
            style: GoogleFonts.montserrat(
              fontSize: fs(13),
              fontWeight: FontWeight.w700,
              color: CustomersLoginThemeView.textDark,
            ),
          ),
          SizedBox(height: scaleF(8)),
          ...UpiAppOption.values.map(
            (app) => _RadioTile(
              label: app.label,
              selected: app == selected,
              onTap: () => onSelect(app),
              fs: fs,
              scaleF: scaleF,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayAtDeliverySection extends StatelessWidget {
  final double Function(double) fs;
  final double Function(double) scaleF;

  const _PayAtDeliverySection({required this.fs, required this.scaleF});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(scaleF(14), 0, scaleF(14), scaleF(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          SizedBox(height: scaleF(12)),
          Text(
            'Payment Information',
            style: GoogleFonts.montserrat(
              fontSize: fs(13),
              fontWeight: FontWeight.w700,
              color: CustomersLoginThemeView.textDark,
            ),
          ),
          SizedBox(height: scaleF(8)),
          Text(
            'Please scan the delivery QR code and complete payment after receiving your order.',
            style: GoogleFonts.montserrat(
              fontSize: fs(12),
              color: CustomersLoginThemeView.textGrey,
              height: 1.4,
            ),
          ),
          SizedBox(height: scaleF(12)),
          _deliveryInfoRow('🚚', 'Estimated Delivery:', 'Within 20 minutes'),
          SizedBox(height: scaleF(8)),
          _deliveryInfoRow('⏰', 'Delivery Hours:', 'Morning 5:00 AM to Night 9:00 PM'),
        ],
      ),
    );
  }

  Widget _deliveryInfoRow(String emoji, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: TextStyle(fontSize: fs(16))),
        SizedBox(width: scaleF(8)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.montserrat(
                fontSize: fs(12),
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
  final double Function(double) fs;
  final double Function(double) scaleF;

  const _RadioTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.fs,
    required this.scaleF,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: scaleF(6)),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: scaleF(20).clamp(16.0, 24.0),
              color: selected
                  ? CustomersLoginThemeView.primaryBlue
                  : CustomersLoginThemeView.textGrey,
            ),
            SizedBox(width: scaleF(10)),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: fs(13),
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
