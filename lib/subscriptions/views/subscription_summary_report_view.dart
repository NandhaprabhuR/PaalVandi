import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/subscriptions_viewmodel.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/services/haptic_service.dart';

class SubscriptionSummaryReportView extends StatefulWidget {
  const SubscriptionSummaryReportView({super.key});

  @override
  State<SubscriptionSummaryReportView> createState() => _SubscriptionSummaryReportViewState();
}

class _SubscriptionSummaryReportViewState extends State<SubscriptionSummaryReportView> {
  int _selectedMonth = 6; // June by default
  int _selectedYear = 2026;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<SubscriptionsViewModel>().add(
          LoadSummaryReport(_selectedMonth, _selectedYear),
        );
  }

  @override
  Widget build(BuildContext context) {
    final scaleF =
        (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs =
        (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: PaalvandiTheme.bgCream,
      appBar: AppBar(
        backgroundColor: PaalvandiTheme.bgCream,
        elevation: 0,
        title: Text(
          'Summary Report',
          style: GoogleFonts.montserrat(
            fontSize: fs(16),
            fontWeight: FontWeight.bold,
            color: PaalvandiTheme.deliveredGreen, // Green Heading
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PaalvandiTheme.textDark),
          onPressed: () {
            HapticService.light();
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<SubscriptionsViewModel, SubscriptionsState>(
        builder: (context, state) {
          if (state.isBillingLoading || state.summaryReport == null) {
            return Center(child: CircularProgressIndicator(color: PaalvandiTheme.primaryBlue));
          }

          final report = state.summaryReport!;

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
            children: [
              // ─── MONTH SELECTOR ───
              Container(
                padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(6)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Report Month:',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textDark,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: scaleF(12)),
                      decoration: BoxDecoration(
                        color: PaalvandiTheme.bgCream,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedMonth,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              HapticService.light();
                              setState(() {
                                _selectedMonth = newValue;
                              });
                              _loadReport();
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('January 2026')),
                            DropdownMenuItem(value: 2, child: Text('February 2026')),
                            DropdownMenuItem(value: 3, child: Text('March 2026')),
                            DropdownMenuItem(value: 4, child: Text('April 2026')),
                            DropdownMenuItem(value: 5, child: Text('May 2026')),
                            DropdownMenuItem(value: 6, child: Text('June 2026')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: scaleF(12)),

              // ─── OVERALL DISPATCH SUMMARY CARD ───
              Container(
                padding: EdgeInsets.all(scaleF(16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Combined Delivery Log Summary',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.deliveredGreen, // Green Heading
                      ),
                    ),
                    const Divider(color: PaalvandiTheme.dividerColor),
                    SizedBox(height: scaleF(8)),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: scaleF(10),
                      crossAxisSpacing: scaleF(10),
                      childAspectRatio: 1.3,
                      children: [
                        _buildMetricCell('Days in Month', '${report.totalCalendarDays}', PaalvandiTheme.textDark, scaleF, fs),
                        _buildMetricCell('Total Deliveries', '${report.deliveredDays}', PaalvandiTheme.deliveredGreen, scaleF, fs),
                        _buildMetricCell('Vacation Days', '${report.vacationDays}', PaalvandiTheme.statusError, scaleF, fs),
                        _buildMetricCell('Paused Days', '${report.pausedDays}', PaalvandiTheme.statusWarning, scaleF, fs),
                        _buildMetricCell('Skipped Days', '${report.skippedDays}', Colors.purple, scaleF, fs),
                        _buildMetricCell('Total Volume', '${report.deliveredQuantity.toStringAsFixed(1)}L', PaalvandiTheme.primaryBlue, scaleF, fs),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: scaleF(12)),

              // ─── COMBINED FINANCIALS CARD ───
              Container(
                padding: EdgeInsets.all(scaleF(16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Combined Route Financials',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.deliveredGreen, // Green Heading
                      ),
                    ),
                    const Divider(color: PaalvandiTheme.dividerColor),
                    SizedBox(height: scaleF(8)),
                    _buildFinancialRow('Milk Amount (Sales)', '₹${report.milkAmount.toStringAsFixed(0)}', scaleF, fs),
                    SizedBox(height: scaleF(6)),
                    _buildFinancialRow('Delivery Charges (Aggregate)', '₹${report.deliveryCharges.toStringAsFixed(0)}', scaleF, fs),
                    SizedBox(height: scaleF(6)),
                    _buildFinancialRow('Advance Payments Credited', '₹${report.advancePaid.toStringAsFixed(0)}', scaleF, fs),
                    SizedBox(height: scaleF(6)),
                    _buildFinancialRow('Net Remaining Balance Due', '₹${report.remainingBalance.toStringAsFixed(0)}', scaleF, fs),
                    SizedBox(height: scaleF(8)),
                    const Divider(color: PaalvandiTheme.dividerColor),
                    SizedBox(height: scaleF(8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Final Payable Amount',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: FontWeight.w900,
                            color: PaalvandiTheme.textDark,
                          ),
                        ),
                        Text(
                          '₹${report.finalPayableAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(14),
                            fontWeight: FontWeight.w900,
                            color: report.finalPayableAmount >= 0 ? PaalvandiTheme.statusWarning : PaalvandiTheme.deliveredGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: scaleF(24)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCell(String label, String value, Color color, Function scaleF, Function fs) {
    return Container(
      padding: EdgeInsets.all(scaleF(6)),
      decoration: BoxDecoration(
        color: PaalvandiTheme.bgLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PaalvandiTheme.dividerColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: fs(8),
              fontWeight: FontWeight.bold,
              color: PaalvandiTheme.textSecondary,
            ),
          ),
          SizedBox(height: scaleF(4)),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: fs(11),
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, Function scaleF, Function fs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: fs(11),
            fontWeight: FontWeight.w600,
            color: PaalvandiTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: fs(11),
            fontWeight: FontWeight.w900,
            color: PaalvandiTheme.textDark,
          ),
        ),
      ],
    );
  }
}
