import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/subscription_plan_model.dart';
import '../models/booked_subscription_model.dart';
import '../models/subscription_quote_model.dart';
import '../viewmodels/subscriptions_booking_store.dart';
import '../viewmodels/subscriptions_scope.dart';
import 'subscription_payment_selection_view.dart';
import '../../core/widgets/paalvandi_confirm_dialog.dart';
import 'modify_subscription_view.dart';
import 'cancel_subscription_view.dart';
import 'delivery_calendar_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../profile/viewmodels/customers_profile_viewmodel.dart';
import '../../core/services/haptic_service.dart';

class YourSubscriptionsView extends StatelessWidget {
  const YourSubscriptionsView({super.key});

  SubscriptionPlan? _planFor(String title) {
    for (final p in SubscriptionPlans.all) {
      if (p.title == title) return p;
    }
    return null;
  }

  Color _accentColorFor(String title) {
    if (title.contains('Family')) return const Color(0xFF1976D2); // Elegant Blue
    if (title.contains('Business')) return const Color(0xFFF57C00); // Premium Orange
    if (title.contains('Event')) return const Color(0xFF8E24AA); // Royal Purple
    if (title.contains('Smart')) return const Color(0xFF4CAF50); // Vibrant Green
    return const Color(0xFF1976D2);
  }

  Future<void> _downloadReceipt(BuildContext context, BookedSubscription booking) async {
    HapticService.lightImpact();
    String cleanText(String text) {
      return text
          .replaceAll('•', '-')
          .replaceAll('–', '-')
          .replaceAll('—', '-')
          .replaceAll('→', '->')
          .replaceAll('₹', 'Rs.');
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pdfCtx) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PAALVANDI',
                          style: pw.TextStyle(
                            fontSize: 26,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Delivering Pure Milk Everyday',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'SUBSCRIPTION RECEIPT',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          DateFormat('dd MMM yyyy · hh:mm a').format(booking.bookedAt),
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Divider(thickness: 1.5, color: PdfColors.blue800),
                pw.SizedBox(height: 20),

                pw.Text(
                  cleanText(booking.planTitle),
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Status: ACTIVE',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800,
                  ),
                ),
                pw.SizedBox(height: 16),

                pw.Text(
                  'Configuration Summary:',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: booking.configSummary.map((line) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 2),
                        child: pw.Text(cleanText('- $line'), style: const pw.TextStyle(fontSize: 10)),
                      );
                    }).toList(),
                  ),
                ),
                pw.SizedBox(height: 16),

                pw.Text(
                  'Pricing Breakdown:',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                ...booking.rateLines.map((line) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Text(cleanText('- $line'), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                  );
                }),
                pw.SizedBox(height: 20),

                pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Monthly bill amount:', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('Rs. ${booking.monthlyBillRupees}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Advance paid:', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('Rs. ${booking.advanceRupees}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Balance amount dues:', style: const pw.TextStyle(fontSize: 11, color: PdfColors.red800)),
                    pw.Text('Rs. ${booking.balanceOnFullPaymentRupees}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                  ],
                ),
                pw.Spacer(),
                pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.Text(
                    'Thank you for subscribing with PaalVandi! For support, contact 9361051718.',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'PaalVandi_${booking.planTitle.replaceAll(' ', '_')}_Receipt.pdf',
    );
  }

  void _payBalanceAmount(
      BuildContext context, SubscriptionsBookingStore store, BookedSubscription booking) {
    HapticService.mediumImpact();
    final quote = SubscriptionQuote(
      planTitle: booking.planTitle,
      backgroundColor: Colors.white,
      configSummary: List.from(booking.configSummary),
      rateLines: booking.rateLines.map((line) {
        final parts = line.split(':');
        final label = parts.isNotEmpty ? parts[0].trim() : 'Rate';
        final valStr = parts.length > 1 ? parts[1].replaceAll('₹', '').replaceAll('days', '').trim() : '0';
        final amount = int.tryParse(valStr) ?? 0;
        return SubscriptionBillLine(label: label, amountRupees: amount);
      }).toList(),
      monthlyMilkRupees: booking.monthlyMilkRupees,
      deliveryChargeRupees: booking.deliveryChargeRupees,
      monthlyBillRupees: booking.monthlyBillRupees,
      advanceRupees: booking.advanceRupees,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubscriptionsScope(
          store: store,
          child: SubscriptionPaymentSelectionView(
            quote: quote,
            payingBalanceOnly: true,
            targetBooking: booking,
          ),
        ),
      ),
    );
  }

  void _cancelSubscription(
      BuildContext context, SubscriptionsBookingStore store, BookedSubscription booking) {
    HapticService.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubscriptionsScope(
          store: store,
          child: CancelSubscriptionView(booking: booking),
        ),
      ),
    );
  }

  void _modifySubscription(
      BuildContext context, SubscriptionsBookingStore store, BookedSubscription booking) {
    HapticService.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubscriptionsScope(
          store: store,
          child: ModifySubscriptionView(booking: booking),
        ),
      ),
    );
  }

  Color _getStatusBadgeBgColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF2E7D32).withValues(alpha: 0.1);
      case 'Paused':
        return const Color(0xFFE65100).withValues(alpha: 0.1);
      case 'Expiring Soon':
        return const Color(0xFFF57F17).withValues(alpha: 0.1);
      case 'Cancelled':
        return const Color(0xFFC62828).withValues(alpha: 0.1);
      default:
        return const Color(0xFF2E7D32).withValues(alpha: 0.1);
    }
  }

  Color _getStatusBadgeTextColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF2E7D32);
      case 'Paused':
        return const Color(0xFFE65100);
      case 'Expiring Soon':
        return const Color(0xFFF57F17);
      case 'Cancelled':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  Future<void> _pauseSubscription(
      BuildContext context, SubscriptionsBookingStore store, BookedSubscription booking) async {
    final start = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: 'Select Pause Start Date',
    );
    if (start == null) return;
    HapticService.selection();

    if (!context.mounted) return;
    final end = await showDatePicker(
      context: context,
      initialDate: start.add(const Duration(days: 5)),
      firstDate: start.add(const Duration(days: 1)),
      lastDate: start.add(const Duration(days: 90)),
      helpText: 'Select Pause End Date',
    );
    if (end == null) return;
    HapticService.selection();

    HapticService.mediumImpact();
    store.pauseBooking(booking, start, end);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Subscription paused from ${DateFormat('dd MMM').format(start)} to ${DateFormat('dd MMM').format(end)}',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          backgroundColor: CustomersLoginThemeView.primaryBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _resumeSubscription(
      BuildContext context, SubscriptionsBookingStore store, BookedSubscription booking) {
    HapticService.mediumImpact();
    store.resumeBooking(booking);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Subscription resumed successfully!',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _renewSubscription(
      BuildContext context, SubscriptionsBookingStore store, BookedSubscription booking) async {
    final confirmed = await showPaalvandiConfirmDialog(
      context,
      title: 'Renew Subscription?',
      message: 'Would you like to renew ${booking.planTitle} for the next month?',
      noLabel: 'Cancel',
      yesLabel: 'Renew Now',
    );

    if (confirmed == true && context.mounted) {
      HapticService.mediumImpact();
      final renewedBooking = BookedSubscription(
        planTitle: booking.planTitle,
        bookedAt: DateTime.now().add(const Duration(days: 30)),
        configSummary: List.from(booking.configSummary),
        rateLines: List.from(booking.rateLines),
        monthlyMilkRupees: booking.monthlyMilkRupees,
        deliveryChargeRupees: booking.deliveryChargeRupees,
        monthlyBillRupees: booking.monthlyBillRupees,
        advanceRupees: booking.advanceRupees,
        balanceOnFullPaymentRupees: booking.balanceOnFullPaymentRupees,
        isFullyPaid: false,
      );
      store.addBooking(renewedBooking);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${booking.planTitle} renewed successfully for next month!',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          backgroundColor: CustomersLoginThemeView.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
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
            actions: [
              if (bookings.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.calendar_month_rounded,
                    color: _accentColorFor(bookings.first.planTitle),
                    size: 26,
                  ),
                  tooltip: 'View Delivery Timeline',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SubscriptionsScope(
                          store: store,
                          child: DeliveryCalendarView(booking: bookings.first),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(width: 8),
            ],
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
                          color: Colors.black,
                          width: 1,
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
                              // Receipt Download Button next to Heading
                              IconButton(
                                icon: const Icon(
                                  Icons.download_rounded,
                                  color: CustomersLoginThemeView.primaryBlue,
                                  size: 24,
                                ),
                                tooltip: 'Download Invoice',
                                onPressed: () => _downloadReceipt(context, booking),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Subscription ID: S8Y2K',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Confirmed · $dateStr',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: CustomersLoginThemeView.textGrey,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getStatusBadgeBgColor(booking.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  booking.status.toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusBadgeTextColor(booking.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (booking.status == 'Paused' && booking.pauseStartDate != null && booking.pauseEndDate != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFFB74D), width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  const Text('⏸️', style: TextStyle(fontSize: 12)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Paused: ${DateFormat('dd MMM yyyy').format(booking.pauseStartDate!)} to ${DateFormat('dd MMM yyyy').format(booking.pauseEndDate!)}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFE65100),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                                // Highlighted Dues Balance Amount Dues if unpaid
                                _historyRow(
                                  'Balance on full payment',
                                  '₹${booking.balanceOnFullPaymentRupees}',
                                  highlight: !booking.isFullyPaid,
                                ),
                                const Divider(height: 12, thickness: 0.5),
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
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Delivery Address:',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: CustomersLoginThemeView.textDark,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              displayAddress,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: CustomersLoginThemeView.textGrey,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 38,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => SubscriptionsScope(
                                            store: store,
                                            child: DeliveryCalendarView(booking: booking),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.calendar_month, size: 16),
                                    label: Text(
                                      'View Calendar',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: CustomersLoginThemeView.primaryBlue,
                                      side: const BorderSide(
                                        color: CustomersLoginThemeView.primaryBlue,
                                        width: 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 38,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _downloadReceipt(context, booking),
                                    icon: const Icon(Icons.download_rounded, size: 16),
                                    label: Text(
                                      'Download Receipt',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: CustomersLoginThemeView.primaryBlue,
                                      side: const BorderSide(
                                        color: CustomersLoginThemeView.primaryBlue,
                                        width: 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Option buttons at the bottom of card
                          if (booking.status != 'Cancelled') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 38,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _modifySubscription(context, store, booking),
                                      icon: const Icon(Icons.edit_note, size: 18),
                                      label: Text(
                                        'Modify',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: CustomersLoginThemeView.primaryBlue,
                                        side: const BorderSide(
                                          color: CustomersLoginThemeView.primaryBlue,
                                          width: 1.2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    height: 38,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        if (booking.status == 'Paused') {
                                          _resumeSubscription(context, store, booking);
                                        } else {
                                          _pauseSubscription(context, store, booking);
                                        }
                                      },
                                      icon: Icon(
                                        booking.status == 'Paused'
                                            ? Icons.play_arrow_outlined
                                            : Icons.pause_circle_outline,
                                        size: 16,
                                      ),
                                      label: Text(
                                        booking.status == 'Paused' ? 'Resume' : 'Pause',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: booking.status == 'Paused'
                                            ? Colors.green.shade800
                                            : Colors.orange.shade800,
                                        side: BorderSide(
                                          color: booking.status == 'Paused'
                                              ? Colors.green.shade800
                                              : Colors.orange.shade800,
                                          width: 1.2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    height: 38,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _cancelSubscription(context, store, booking),
                                      icon: const Icon(Icons.cancel_outlined, size: 16),
                                      label: Text(
                                        'Cancel',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: CustomersLoginThemeView.sectionHeadingRed,
                                        side: const BorderSide(
                                          color: CustomersLoginThemeView.sectionHeadingRed,
                                          width: 1.2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Pay Balance or Renew Buttons
                            if (!booking.isFullyPaid && booking.balanceOnFullPaymentRupees > 0) ...[
                              SizedBox(
                                width: double.infinity,
                                height: 38,
                                child: ElevatedButton.icon(
                                  onPressed: () => _payBalanceAmount(context, store, booking),
                                  icon: const Icon(Icons.payments_outlined, size: 18),
                                  label: Text(
                                    'Pay Balance (₹${booking.balanceOnFullPaymentRupees})',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              SizedBox(
                                width: double.infinity,
                                height: 38,
                                child: ElevatedButton.icon(
                                  onPressed: () => _renewSubscription(context, store, booking),
                                  icon: const Icon(Icons.autorenew, size: 18),
                                  label: Text(
                                    'Renew for Next Month',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomersLoginThemeView.primaryBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ] else ...[
                            // If Cancelled, show a re-purchase button
                            SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: ElevatedButton.icon(
                                onPressed: () => _renewSubscription(context, store, booking),
                                icon: const Icon(Icons.autorenew, size: 18),
                                label: Text(
                                  'Re-purchase Subscription',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomersLoginThemeView.primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _historyRow(String label, String value, {bool bold = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: bold || highlight ? FontWeight.w800 : FontWeight.w500,
              color: highlight ? CustomersLoginThemeView.sectionHeadingRed : CustomersLoginThemeView.textDark,
            ),
          ),
          Container(
            padding: highlight ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2) : null,
            decoration: highlight ? BoxDecoration(
              color: CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ) : null,
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: highlight ? CustomersLoginThemeView.sectionHeadingRed : CustomersLoginThemeView.priceAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
