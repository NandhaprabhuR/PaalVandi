import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/subscriptions_viewmodel.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/services/haptic_service.dart';

class SubscriptionMonthlyHistoryView extends StatefulWidget {
  final String subscriptionId;

  const SubscriptionMonthlyHistoryView({super.key, required this.subscriptionId});

  @override
  State<SubscriptionMonthlyHistoryView> createState() => _SubscriptionMonthlyHistoryViewState();
}

class _SubscriptionMonthlyHistoryViewState extends State<SubscriptionMonthlyHistoryView> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionsViewModel>().add(LoadBillingHistory(widget.subscriptionId));
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
          'Billing History',
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
          if (state.isBillingLoading) {
            return Center(child: CircularProgressIndicator(color: PaalvandiTheme.primaryBlue));
          }

          if (state.billingHistory.isEmpty) {
            return Center(
              child: Text(
                'No billing records found',
                style: GoogleFonts.montserrat(
                  fontSize: fs(12),
                  fontWeight: FontWeight.bold,
                  color: PaalvandiTheme.textSecondary,
                ),
              ),
            );
          }

          // Reverse chronological history list (latest June first, down to January)
          final historyList = state.billingHistory.reversed.toList();

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
            itemCount: historyList.length,
            separatorBuilder: (_, __) => SizedBox(height: scaleF(12)),
            itemBuilder: (context, index) {
              final stmt = historyList[index];
              return Container(
                padding: EdgeInsets.all(scaleF(14)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month/Year header and Payment Status badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined, color: PaalvandiTheme.primaryBlue, size: scaleF(18)),
                            SizedBox(width: scaleF(6)),
                            Text(
                              '${stmt.monthName} ${stmt.year}',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(13),
                                fontWeight: FontWeight.bold,
                                color: PaalvandiTheme.deliveredGreen, // Green Heading
                              ),
                            ),
                          ],
                        ),
                        _buildPaymentBadge(stmt.paymentStatus, scaleF, fs),
                      ],
                    ),
                    const Divider(color: PaalvandiTheme.dividerColor),
                    SizedBox(height: scaleF(6)),

                    // Days stats summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatsSummaryCell('Days', '${stmt.calendarDays} Days', scaleF, fs),
                        _buildStatsSummaryCell('Delivered', '${stmt.deliveredDays}', scaleF, fs),
                        _buildStatsSummaryCell('Vacation', '${stmt.vacationDays}', scaleF, fs),
                        _buildStatsSummaryCell('Paused/Skip', '${stmt.pausedDays + stmt.skippedDays}', scaleF, fs),
                      ],
                    ),
                    SizedBox(height: scaleF(10)),
                    const Divider(color: PaalvandiTheme.dividerColor),
                    SizedBox(height: scaleF(8)),

                    // Billing details and totals
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivered Qty: ${stmt.deliveredQuantity.toStringAsFixed(1)}L',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(11),
                                fontWeight: FontWeight.bold,
                                color: PaalvandiTheme.textDark,
                              ),
                            ),
                            Text(
                              'Milk Rate: ₹${stmt.ratePerLiter.toStringAsFixed(0)}/L',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(9),
                                fontWeight: FontWeight.bold,
                                color: PaalvandiTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Bill: ₹${stmt.monthlyBill.toStringAsFixed(0)}',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(11),
                                fontWeight: FontWeight.bold,
                                color: PaalvandiTheme.textDark,
                              ),
                            ),
                            Text(
                              'Remaining: ₹${stmt.remainingBalance.toStringAsFixed(0)}',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(9),
                                fontWeight: FontWeight.bold,
                                color: stmt.remainingBalance > 0 ? PaalvandiTheme.statusWarning : PaalvandiTheme.deliveredGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatsSummaryCell(String label, String value, Function scaleF, Function fs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: fs(9),
            fontWeight: FontWeight.w600,
            color: PaalvandiTheme.textSecondary,
          ),
        ),
        SizedBox(height: scaleF(2)),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: fs(11),
            fontWeight: FontWeight.bold,
            color: PaalvandiTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentBadge(String status, Function scaleF, Function fs) {
    Color color;
    Color bgColor;

    switch (status) {
      case 'Paid':
        color = PaalvandiTheme.deliveredGreen;
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 'Partial':
        color = PaalvandiTheme.statusWarning;
        bgColor = const Color(0xFFFFF3E0);
        break;
      default:
        color = PaalvandiTheme.statusError;
        bgColor = const Color(0xFFFFEBEE);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: scaleF(6), vertical: scaleF(2)),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        status,
        style: GoogleFonts.montserrat(
          fontSize: fs(8),
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
