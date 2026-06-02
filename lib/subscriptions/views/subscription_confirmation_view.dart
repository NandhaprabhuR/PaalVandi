import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../models/subscription_quote_model.dart';
import '../viewmodels/subscriptions_scope.dart';
import 'subscription_payment_selection_view.dart';

class SubscriptionConfirmationView extends StatelessWidget {
  final SubscriptionQuote quote;

  const SubscriptionConfirmationView({super.key, required this.quote});

  void _payAdvance(BuildContext context) {
    final store = SubscriptionsScope.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SubscriptionsScope(
          store: store,
          child: SubscriptionPaymentSelectionView(quote: quote),
        ),
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
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
                // Header / Brand Name
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
                          'INVOICE BILL',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          DateFormat('dd MMM yyyy').format(DateTime.now()),
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

                // Invoice Title / Plan Name
                pw.Text(
                  cleanText(quote.planTitle),
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                  ),
                ),
                pw.SizedBox(height: 16),

                // Configuration Summary Section
                pw.Text(
                  'Subscription Details:',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: quote.configSummary.map((line) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Text(
                          cleanText('- $line'),
                          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey900),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                pw.SizedBox(height: 24),

                // Rates Section
                pw.Text(
                  'Monthly Pricing & Breakdown:',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    for (final line in quote.rateLines)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              cleanText(line.label),
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: line.label.contains('total') || line.label.contains('Total')
                                    ? pw.FontWeight.bold
                                    : pw.FontWeight.normal,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              line.label == 'Estimated days'
                                  ? '${line.amountRupees} days'
                                  : 'Rs. ${line.amountRupees}',
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: line.label.contains('total') || line.label.contains('Total')
                                    ? pw.FontWeight.bold
                                    : pw.FontWeight.normal,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Delivery charge',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Rs. ${quote.deliveryChargeRupees}',
                            style: const pw.TextStyle(fontSize: 11),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Monthly bill amount',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Rs. ${quote.monthlyBillRupees}',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Payment Breakdown Section
                pw.Text(
                  'Payment Summary:',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColors.blue300, width: 0.8),
                    color: PdfColors.blue50,
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Advance payable now:',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                          ),
                          pw.Text(
                            'Rs. ${quote.advanceRupees}',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Balance on full payment:',
                            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
                          ),
                          pw.Text(
                            'Rs. ${quote.balanceOnFullPaymentRupees}',
                            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),

                // Footer
                pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.Text(
                    'Thank you for subscribing with PaalVandi! For support, contact 9361051718.',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Share/Download PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${quote.planTitle.replaceAll(' ', '_')}_Invoice.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

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
            fontSize: fs(22),
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _downloadPdf(context),
            tooltip: 'Download Invoice PDF',
            icon: Icon(
              Icons.download_rounded,
              color: CustomersLoginThemeView.primaryBlue,
              size: scaleF(24),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPadding, scaleF(4), hPadding, scaleF(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      quote.planTitle,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(18),
                        fontWeight: FontWeight.w800,
                        color: CustomersLoginThemeView.sectionHeadingRed,
                      ),
                    ),
                    SizedBox(height: scaleF(8)),
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
                                    fontSize: fs(13),
                                    fontWeight: FontWeight.w500,
                                    color: CustomersLoginThemeView.textDark,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    SizedBox(height: scaleF(12)),
                    Text(
                      'Monthly rates',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(15),
                        fontWeight: FontWeight.w800,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(8)),
                    _infoCard(
                      child: Column(
                        children: [
                          for (final line in quote.rateLines)
                            _billRow(
                              line.label,
                              line.amountRupees,
                              fs,
                              bold: line.label.contains('total') ||
                                  line.label.contains('Total'),
                            ),
                          const Divider(height: 20),
                          _billRow(
                            'Delivery charge',
                            quote.deliveryChargeRupees,
                            fs,
                            accent: true,
                          ),
                          const SizedBox(height: 6),
                          _billRow(
                            'Monthly bill amount',
                            quote.monthlyBillRupees,
                            fs,
                            bold: true,
                            large: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: scaleF(12)),
                    _noteBanner(
                      icon: Icons.local_shipping_outlined,
                      text: 'No delivery charge for this subscription payment.',
                      color: CustomersLoginThemeView.primaryBlue,
                    ),
                    SizedBox(height: scaleF(8)),
                    _noteBanner(
                      icon: Icons.payments_outlined,
                      text:
                          'Pay ₹${quote.advanceRupees} advance now to confirm your subscription. This amount will be adjusted and deducted from your full monthly payment.',
                      color: CustomersLoginThemeView.sectionHeadingRed,
                    ),
                    SizedBox(height: scaleF(8)),
                    _infoCard(
                      child: Column(
                        children: [
                          _billRow(
                            'Advance payable now',
                            quote.advanceRupees,
                            fs,
                            bold: true,
                          ),
                          _billRow(
                            'Balance on full payment',
                            quote.balanceOnFullPaymentRupees,
                            fs,
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
                hPadding,
                scaleF(8),
                hPadding,
                scaleF(16) + MediaQuery.paddingOf(context).bottom,
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
                      fontSize: fs(15),
                      fontWeight: FontWeight.w700,
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

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _billRow(
    String label,
    int amount,
    double Function(double) fs, {
    bool bold = false,
    bool large = false,
    bool accent = false,
  }) {
    final display = label == 'Estimated days' ? '$amount days' : '₹$amount';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: fs(large ? 15 : 13),
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
              fontSize: fs(large ? 18 : 14),
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
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
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
