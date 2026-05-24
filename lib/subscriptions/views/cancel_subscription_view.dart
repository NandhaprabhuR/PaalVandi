import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../models/booked_subscription_model.dart';
import '../viewmodels/subscriptions_scope.dart';
import '../models/subscription_quote_model.dart';
import 'subscription_payment_selection_view.dart';

class CancelSubscriptionView extends StatefulWidget {
  final BookedSubscription booking;

  const CancelSubscriptionView({super.key, required this.booking});

  @override
  State<CancelSubscriptionView> createState() => _CancelSubscriptionViewState();
}

class _CancelSubscriptionViewState extends State<CancelSubscriptionView> {
  String? _selectedReason;
  String _selectedTerm = 'Cancel Immediately';

  final _otherReasonController = TextEditingController();
  bool _hasVoiceNote = false;
  bool _isPlayingVoice = false;

  final List<String> _reasons = [
    'Sour Milk',
    'Late Delivery',
    'Price is High',
    'No longer needed',
    'Other',
  ];

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  void _startVoiceAutofill() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Listening...',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  color: CustomersLoginThemeView.primaryBlue,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Speak now to describe why you want to cancel...',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CustomersLoginThemeView.textGrey,
                ),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _otherReasonController.text =
              'The subscription pricing is currently a bit high for my daily usage, and I\'d like to try other alternatives for now.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Voice note transcribed successfully!',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _recordVoiceMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Recording Voice Message...',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.sectionHeadingRed,
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.fiber_manual_record,
                color: CustomersLoginThemeView.sectionHeadingRed,
                size: 48,
              ),
              const SizedBox(height: 24),
              Text(
                'Speak now to attach your voice note...',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CustomersLoginThemeView.textGrey,
                ),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _hasVoiceNote = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Voice note attached successfully!',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    // Dynamic Refund/Due Calculations
    final now = DateTime.now();
    final difference = now.difference(widget.booking.bookedAt);
    final daysUsed = difference.inDays.clamp(0, 30);
    final daysRemaining = 30 - daysUsed;
    final amountPaid = widget.booking.isFullyPaid
        ? widget.booking.monthlyBillRupees
        : widget.booking.advanceRupees;
    
    final refundAmount = ((amountPaid * daysRemaining) / 30).round();
    final remainingDaysBalance = ((widget.booking.monthlyBillRupees * daysRemaining) / 30).round();

    final bool requiresPaymentAtMonthEnd = _selectedTerm == 'Cancel at Month End' && !widget.booking.isFullyPaid;

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cancel Subscription',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(19),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Details Summary Card
                    Container(
                      padding: EdgeInsets.all(scaleF(16)),
                      decoration: BoxDecoration(
                        color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: CustomersLoginThemeView.primaryBlue,
                            size: scaleF(24),
                          ),
                          SizedBox(width: scaleF(14)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.booking.planTitle,
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(15),
                                    fontWeight: FontWeight.bold,
                                    color: CustomersLoginThemeView.primaryBlue,
                                  ),
                                ),
                                SizedBox(height: scaleF(4)),
                                Text(
                                  'Booked on ${DateFormat('dd MMM yyyy').format(widget.booking.bookedAt)}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(12),
                                    color: CustomersLoginThemeView.textGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: scaleF(24)),

                    // Reasons section
                    Text(
                      'Why would you like to cancel?',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(12)),
                    Wrap(
                      spacing: scaleF(8),
                      runSpacing: scaleF(8),
                      children: _reasons.map((r) {
                        final selected = _selectedReason == r;
                        return ChoiceChip(
                          label: Text(r),
                          selected: selected,
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedReason = r);
                            }
                          },
                          selectedColor: CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.1),
                          checkmarkColor: CustomersLoginThemeView.sectionHeadingRed,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: selected
                                ? CustomersLoginThemeView.sectionHeadingRed
                                : CustomersLoginThemeView.borderColor,
                            width: selected ? 1.5 : 1.0,
                          ),
                          labelStyle: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                            color: selected
                                ? CustomersLoginThemeView.sectionHeadingRed
                                : CustomersLoginThemeView.textDark,
                          ),
                        );
                      }).toList(),
                    ),
                    
                    if (_selectedReason == 'Other') ...[
                      SizedBox(height: scaleF(16)),
                      Text(
                        'Mention Reason',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(13),
                          fontWeight: FontWeight.bold,
                          color: CustomersLoginThemeView.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(8)),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _otherReasonController,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(13),
                                  color: CustomersLoginThemeView.textDark,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Please describe why you would like to cancel your subscription...',
                                  hintStyle: GoogleFonts.montserrat(
                                    fontSize: fs(12),
                                    color: CustomersLoginThemeView.textGrey,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(scaleF(14)),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.mic_rounded, color: CustomersLoginThemeView.primaryBlue),
                              tooltip: 'Autofill with Voice',
                              onPressed: _startVoiceAutofill,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: scaleF(10)),
                      if (!_hasVoiceNote)
                        OutlinedButton.icon(
                          onPressed: _recordVoiceMessage,
                          icon: const Icon(Icons.mic_none_outlined, size: 18),
                          label: Text(
                            'Record & Send Voice Message',
                            style: GoogleFonts.montserrat(fontSize: fs(12), fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CustomersLoginThemeView.primaryBlue,
                            side: const BorderSide(color: CustomersLoginThemeView.primaryBlue, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: scaleF(12), vertical: scaleF(8)),
                          decoration: BoxDecoration(
                            color: CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isPlayingVoice ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                  color: CustomersLoginThemeView.sectionHeadingRed,
                                  size: scaleF(28),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPlayingVoice = !_isPlayingVoice;
                                  });
                                },
                              ),
                              SizedBox(width: scaleF(6)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Voice Note (0:12)',
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(11),
                                        fontWeight: FontWeight.bold,
                                        color: CustomersLoginThemeView.sectionHeadingRed,
                                      ),
                                    ),
                                    SizedBox(height: scaleF(4)),
                                    LinearProgressIndicator(
                                      value: _isPlayingVoice ? 0.6 : 0.0,
                                      color: CustomersLoginThemeView.sectionHeadingRed,
                                      backgroundColor: CustomersLoginThemeView.borderColor,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: CustomersLoginThemeView.textGrey),
                                onPressed: () {
                                  setState(() {
                                    _hasVoiceNote = false;
                                    _isPlayingVoice = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                    SizedBox(height: scaleF(24)),

                    if (_selectedReason != null) ...[
                      // Terms Selection Dropdown
                      Text(
                        'Select Cancellation Terms',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(13),
                          fontWeight: FontWeight.bold,
                          color: CustomersLoginThemeView.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(8)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: scaleF(12)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: CustomersLoginThemeView.borderColor,
                            width: 1.2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTerm,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: CustomersLoginThemeView.primaryBlue),
                            style: GoogleFonts.montserrat(
                              fontSize: fs(13),
                              fontWeight: FontWeight.w600,
                              color: CustomersLoginThemeView.textDark,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Cancel Immediately',
                                child: Text('Cancel Immediately'),
                              ),
                              DropdownMenuItem(
                                value: 'Cancel at Month End',
                                child: Text('Cancel at Month End'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedTerm = val);
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: scaleF(24)),

                      // Balance Notification / Refund Alert Box
                      Container(
                        padding: EdgeInsets.all(scaleF(16)),
                        decoration: BoxDecoration(
                          color: requiresPaymentAtMonthEnd
                              ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.05)
                              : CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: requiresPaymentAtMonthEnd
                                ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.15)
                                : CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.15),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: requiresPaymentAtMonthEnd
                                  ? CustomersLoginThemeView.primaryBlue
                                  : CustomersLoginThemeView.sectionHeadingRed,
                              size: scaleF(22),
                            ),
                            SizedBox(width: scaleF(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    requiresPaymentAtMonthEnd
                                        ? 'Outstanding Dues'
                                        : 'Refund Notice',
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(13),
                                      fontWeight: FontWeight.bold,
                                      color: requiresPaymentAtMonthEnd
                                          ? CustomersLoginThemeView.primaryBlue
                                          : CustomersLoginThemeView.sectionHeadingRed,
                                    ),
                                  ),
                                  SizedBox(height: scaleF(4)),
                                  Text(
                                    _selectedTerm == 'Cancel at Month End'
                                        ? (widget.booking.isFullyPaid
                                            ? 'No outstanding balance due. Subscription will be cancelled immediately at month end.'
                                            : 'Outstanding balance for remaining days\' delivery: ₹$remainingDaysBalance. You will be redirected to settle this balance before cancellation.')
                                        : 'A balance refund of ₹$refundAmount will be returned in 3 hours without any charge.',
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
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(hPadding, scaleF(12), hPadding, scaleF(16) + MediaQuery.paddingOf(context).bottom),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: scaleF(46).clamp(42.0, 52.0),
                child: ElevatedButton(
                  onPressed: _selectedReason == null
                      ? null
                      : () {
                          final store = SubscriptionsScope.of(context);
                          
                          if (requiresPaymentAtMonthEnd) {
                            // Settle Dues Payment Routing
                            final quote = SubscriptionQuote(
                              planTitle: widget.booking.planTitle,
                              backgroundColor: Colors.white,
                              configSummary: List.from(widget.booking.configSummary),
                              rateLines: widget.booking.rateLines.map((line) {
                                final parts = line.split(':');
                                final label = parts.isNotEmpty ? parts[0].trim() : 'Rate';
                                final valStr = parts.length > 1 ? parts[1].replaceAll('₹', '').replaceAll('days', '').trim() : '0';
                                final amount = int.tryParse(valStr) ?? 0;
                                return SubscriptionBillLine(label: label, amountRupees: amount);
                              }).toList(),
                              monthlyMilkRupees: widget.booking.monthlyMilkRupees,
                              deliveryChargeRupees: widget.booking.deliveryChargeRupees,
                              monthlyBillRupees: remainingDaysBalance,
                              advanceRupees: 0,
                            );

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => SubscriptionsScope(
                                  store: store,
                                  child: SubscriptionPaymentSelectionView(
                                    quote: quote,
                                    payingBalanceOnly: true,
                                    targetBooking: widget.booking,
                                    cancellingAtMonthEnd: true,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            store.cancelBooking(widget.booking);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _selectedTerm == 'Cancel at Month End'
                                      ? '${widget.booking.planTitle} will be cancelled at month end.'
                                      : '${widget.booking.planTitle} cancelled successfully. Refund initiated.',
                                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                                ),
                                backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            Navigator.pop(context); // Pops CancelSubscriptionView
                            Navigator.pop(context); // Pops YourSubscriptionsView
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: requiresPaymentAtMonthEnd
                        ? CustomersLoginThemeView.primaryBlue
                        : CustomersLoginThemeView.sectionHeadingRed,
                    disabledBackgroundColor: CustomersLoginThemeView.borderColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    requiresPaymentAtMonthEnd
                        ? 'Settle Balance & Cancel'
                        : 'Yes, Cancel Finally',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
