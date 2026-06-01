import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../models/subscription_quote_model.dart';
import '../models/booked_subscription_model.dart';
import '../viewmodels/subscriptions_scope.dart';
import '../../payment/views/payment_success_view.dart';

class SubscriptionPaymentSelectionView extends StatefulWidget {
  final SubscriptionQuote quote;
  final bool payingBalanceOnly;
  final BookedSubscription? targetBooking;
  final bool cancellingAtMonthEnd;

  const SubscriptionPaymentSelectionView({
    super.key,
    required this.quote,
    this.payingBalanceOnly = false,
    this.targetBooking,
    this.cancellingAtMonthEnd = false,
  });

  @override
  State<SubscriptionPaymentSelectionView> createState() =>
      _SubscriptionPaymentSelectionViewState();
}

class _SubscriptionPaymentSelectionViewState
    extends State<SubscriptionPaymentSelectionView> {
  bool _payFullAmount = false;
  String _selectedUpiApp = 'Google Pay';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.payingBalanceOnly) {
      _payFullAmount = true;
    }
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Premium loading simulation
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (!mounted) return;
    
    final isPayingBalance = widget.payingBalanceOnly && widget.targetBooking != null;
    
    if (isPayingBalance) {
      if (widget.cancellingAtMonthEnd) {
        SubscriptionsScope.of(context).cancelBooking(widget.targetBooking!);
      } else {
        SubscriptionsScope.of(context).markBookingAsPaid(widget.targetBooking!);
      }
    } else {
      // Register the booked subscription with dynamic amount calculation
      SubscriptionsScope.of(context).addBooking(
        widget.quote.toBooking(payFull: _payFullAmount),
      );
    }
    
    if (!mounted) return;

    // Show the premium full-screen checkmark/animation success screen!
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (successCtx) => PaymentSuccessView(
          paidOnline: true,
          isSubscription: true,
          onFinished: () {
            // Pop success screen
            Navigator.of(successCtx).pop();

            // Perform the pops underneath
            if (isPayingBalance) {
              Navigator.of(context).pop(); // Pops payment screen
              if (widget.cancellingAtMonthEnd) {
                Navigator.of(context).pop(); // Pops YourSubscriptionsView
              }
            } else {
              Navigator.of(context).pop(); // Pops payment screen
              Navigator.of(context).pop(); // Pops configuration confirm screen
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);
    
    final activeTotal = widget.payingBalanceOnly
        ? widget.quote.balanceOnFullPaymentRupees
        : (_payFullAmount 
            ? widget.quote.monthlyBillRupees 
            : widget.quote.advanceRupees);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: CustomersLoginThemeView.themeModeNotifier,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: CustomersLoginThemeView.primaryBlue,
                size: scaleF(24).clamp(20.0, 28.0),
              ),
              onPressed: _isProcessing ? null : () => Navigator.pop(context),
            ),
            title: Text(
              'Subscription Payment',
              style: CustomersLoginThemeView.brandTitleStyle.copyWith(
                fontSize: fs(20),
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
                      widget.payingBalanceOnly
                          ? 'Select your preferred UPI app below to pay the outstanding balance dues.'
                          : 'Choose payment amount option and select your preferred UPI app to confirm your subscription.',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(13),
                        fontWeight: FontWeight.w500,
                        color: CustomersLoginThemeView.textGrey,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: scaleF(16)),
                    
                    if (widget.payingBalanceOnly) ...[
                      Container(
                        padding: EdgeInsets.all(scaleF(14)),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paying Subscription Balance Dues',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(14),
                                fontWeight: FontWeight.bold,
                                color: CustomersLoginThemeView.sectionHeadingRed,
                              ),
                            ),
                            SizedBox(height: scaleF(6)),
                            Text(
                              'You are paying the outstanding balance of ₹${widget.quote.balanceOnFullPaymentRupees} for ${widget.quote.planTitle}. Upon successful payment, your subscription will be marked as fully paid.',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                color: CustomersLoginThemeView.textDark,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // 1. Payment Amount Option Cards
                      Text(
                        'Select Payment Option',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(15),
                          fontWeight: FontWeight.w800,
                          color: CustomersLoginThemeView.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(10)),
                      
                      // Card Option 1: Pay Advance Only
                      _buildAmountOptionCard(
                        title: 'Pay Advance Only',
                        amount: widget.quote.advanceRupees,
                        description: 'Pay a token advance of ₹${widget.quote.advanceRupees} now to secure your deliveries. The remaining balance of ₹${widget.quote.balanceOnFullPaymentRupees} can be settled during your billing cycle.',
                        selected: !_payFullAmount,
                        onTap: () => setState(() => _payFullAmount = false),
                        fs: fs,
                        scaleF: scaleF,
                      ),
                      SizedBox(height: scaleF(10)),
                      
                      // Card Option 2: Pay Full Monthly Bill
                      _buildAmountOptionCard(
                        title: 'Pay Full Monthly Bill',
                        amount: widget.quote.monthlyBillRupees,
                        description: 'Pay the full subscription monthly amount of ₹${widget.quote.monthlyBillRupees} upfront for complete, hassle-free daily deliveries all month long with zero balance dues.',
                        selected: _payFullAmount,
                        onTap: () => setState(() => _payFullAmount = true),
                        fs: fs,
                        scaleF: scaleF,
                      ),
                    ],
                    
                    SizedBox(height: scaleF(20)),
                    
                    // 2. Summary Bill Section
                    _buildBillSummaryCard(activeTotal, fs, scaleF),
                    
                    SizedBox(height: scaleF(20)),
                    
                    // 3. Payment Method Section
                    Text(
                      'Select UPI App',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(15),
                        fontWeight: FontWeight.w800,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(10)),
                    
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(12)),
                      decoration: CustomersLoginThemeView.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('💳', style: TextStyle(fontSize: fs(24))),
                              SizedBox(width: scaleF(10)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Instant UPI Payment',
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(14),
                                      fontWeight: FontWeight.bold,
                                      color: CustomersLoginThemeView.textDark,
                                    ),
                                  ),
                                  Text(
                                    'Secure checkout with instant activation',
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(11),
                                      color: CustomersLoginThemeView.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(
                            color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.5),
                            height: scaleF(20),
                          ),
                          _buildUpiRadioTile('Google Pay', fs, scaleF),
                          _buildUpiRadioTile('PhonePe', fs, scaleF),
                          _buildUpiRadioTile('Paytm', fs, scaleF),
                          _buildUpiRadioTile('BHIM UPI', fs, scaleF),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom Action Button Container
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.fromLTRB(hPadding, scaleF(10), hPadding, scaleF(12)),
                  decoration: BoxDecoration(
                    color: CustomersLoginThemeView.cardBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: CustomersLoginThemeView.isDarkMode ? 0.3 : 0.06),
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
                        onPressed: _isProcessing ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomersLoginThemeView.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? SizedBox(
                                width: scaleF(22),
                                height: scaleF(22),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Pay ₹$activeTotal & Confirm',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(15),
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

  Widget _buildAmountOptionCard({
    required String title,
    required int amount,
    required String description,
    required bool selected,
    required VoidCallback onTap,
    required double Function(double) fs,
    required double Function(double) scaleF,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.04)
            : CustomersLoginThemeView.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black,
          width: selected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.all(scaleF(14)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected 
                    ? CustomersLoginThemeView.primaryBlue 
                    : CustomersLoginThemeView.textGrey,
                size: scaleF(22),
              ),
              SizedBox(width: scaleF(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.montserrat(
                            fontSize: fs(14),
                            fontWeight: FontWeight.bold,
                            color: CustomersLoginThemeView.textDark,
                          ),
                        ),
                        Text(
                          '₹$amount',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(15),
                            fontWeight: FontWeight.w800,
                            color: CustomersLoginThemeView.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: scaleF(6)),
                    Text(
                      description,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        color: CustomersLoginThemeView.textGrey,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillSummaryCard(
    int activeTotal,
    double Function(double) fs,
    double Function(double) scaleF,
  ) {
    return Container(
      padding: EdgeInsets.all(scaleF(14)),
      decoration: CustomersLoginThemeView.cardDecoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plan Monthly Amount',
                style: GoogleFonts.montserrat(
                  fontSize: fs(12),
                  fontWeight: FontWeight.w600,
                  color: CustomersLoginThemeView.textGrey,
                ),
              ),
              Text(
                '₹${widget.quote.monthlyBillRupees}',
                style: GoogleFonts.montserrat(
                  fontSize: fs(13),
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _payFullAmount ? 'Full Payment Selection' : 'Advance Payment Selection',
                style: GoogleFonts.montserrat(
                  fontSize: fs(12),
                  fontWeight: FontWeight.w600,
                  color: CustomersLoginThemeView.textGrey,
                ),
              ),
              Text(
                '₹$activeTotal',
                style: GoogleFonts.montserrat(
                  fontSize: fs(13),
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
            ],
          ),
          if (!_payFullAmount) ...[
            SizedBox(height: scaleF(6)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance Dues Payable Later',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    fontWeight: FontWeight.w600,
                    color: CustomersLoginThemeView.sectionHeadingRed,
                  ),
                ),
                Text(
                  '₹${widget.quote.balanceOnFullPaymentRupees}',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(13),
                    fontWeight: FontWeight.bold,
                    color: CustomersLoginThemeView.sectionHeadingRed,
                  ),
                ),
              ],
            ),
          ],
          Divider(
            color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.5),
            height: scaleF(20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount Payable Now',
                style: GoogleFonts.montserrat(
                  fontSize: fs(14),
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
              Text(
                '₹$activeTotal',
                style: GoogleFonts.montserrat(
                  fontSize: fs(16),
                  fontWeight: FontWeight.w900,
                  color: CustomersLoginThemeView.priceAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpiRadioTile(
    String appName,
    double Function(double) fs,
    double Function(double) scaleF,
  ) {
    final selected = _selectedUpiApp == appName;
    return InkWell(
      onTap: () => setState(() => _selectedUpiApp = appName),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: scaleF(6)),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected 
                  ? CustomersLoginThemeView.primaryBlue 
                  : CustomersLoginThemeView.textGrey,
              size: scaleF(20),
            ),
            SizedBox(width: scaleF(10)),
            Text(
              appName,
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
