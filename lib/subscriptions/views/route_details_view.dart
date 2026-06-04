import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/subscriptions_viewmodel.dart';
import '../models/subscription_delivery_model.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/services/haptic_service.dart';

class RouteDetailsView extends StatefulWidget {
  final String routeName;

  const RouteDetailsView({super.key, required this.routeName});

  @override
  State<RouteDetailsView> createState() => _RouteDetailsViewState();
}

class _RouteDetailsViewState extends State<RouteDetailsView> {
  String? _selectedSkipReason;

  String _getProductImageUrl(String name) {
    if (name.contains('Milk')) {
      return 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&q=80&w=200';
    } else if (name.contains('Curd')) {
      return 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&q=80&w=200';
    } else if (name.contains('Buttermilk')) {
      return 'https://images.unsplash.com/photo-1528498033973-3c07f7b4c26a?auto=format&fit=crop&q=80&w=200';
    }
    return 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&q=80&w=200';
  }

  void _showSkipReasonSheet(BuildContext context, SubscriptionDeliveryModel sub, Function scaleF, Function fs) {
    _selectedSkipReason = 'Customer Not Home';
    HapticService.medium();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Colors.black, width: 2),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final reasons = [
              'Customer Not Home',
              'No Bottle Left Outside',
              'Cancelled for Today',
              'Other'
            ];

            return Padding(
              padding: EdgeInsets.fromLTRB(scaleF(20), scaleF(16), scaleF(20), scaleF(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: scaleF(40),
                      height: scaleF(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: scaleF(16)),
                  Text(
                    'Why skip delivery?',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(16),
                      fontWeight: FontWeight.bold,
                      color: PaalvandiTheme.deliveredGreen, // Green heading
                    ),
                  ),
                  SizedBox(height: scaleF(4)),
                  Text(
                    'Select a reason for skipping ${sub.customerName}\'s delivery:',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(11),
                      color: PaalvandiTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: scaleF(16)),
                  ...reasons.map((reason) {
                    final isSelected = _selectedSkipReason == reason;
                    return GestureDetector(
                      onTap: () {
                        HapticService.light();
                        setSheetState(() {
                          _selectedSkipReason = reason;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: scaleF(8)),
                        padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(12)),
                        decoration: BoxDecoration(
                          color: isSelected ? PaalvandiTheme.primaryBlue.withOpacity(0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? PaalvandiTheme.primaryBlue : PaalvandiTheme.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              reason,
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? PaalvandiTheme.primaryBlue : PaalvandiTheme.textDark,
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? PaalvandiTheme.primaryBlue : PaalvandiTheme.textMuted,
                              size: scaleF(18),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: scaleF(16)),
                  GestureDetector(
                    onTap: () {
                      HapticService.heavy();
                      context.read<SubscriptionsViewModel>().add(
                        SkipSubscriptionDelivery(sub.id, _selectedSkipReason ?? 'Other'),
                      );
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Skipped delivery for ${sub.customerName}',
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: PaalvandiTheme.statusError,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: scaleF(14)),
                      decoration: BoxDecoration(
                        color: PaalvandiTheme.statusError,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm Skip',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: fs(13),
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
      },
    );
  }

  void _showBottleCollectionDialog(BuildContext context, SubscriptionDeliveryModel sub, Function scaleF, Function fs) {
    int collected = sub.bottlesCollected;
    HapticService.medium();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              backgroundColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(scaleF(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wine_bar_outlined,
                      size: scaleF(40),
                      color: PaalvandiTheme.primaryBlue,
                    ),
                    SizedBox(height: scaleF(16)),
                    Text(
                      'Collect Bottles',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.deliveredGreen, // Green heading
                      ),
                    ),
                    SizedBox(height: scaleF(6)),
                    Text(
                      '${sub.customerName} has ${sub.pendingBottles} pending bottles.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        color: PaalvandiTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: scaleF(20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (collected > 0) {
                              HapticService.light();
                              setDialogState(() {
                                collected--;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(scaleF(8)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: Icon(Icons.remove, size: scaleF(18), color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: scaleF(24)),
                          child: Text(
                            '$collected',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(24),
                              fontWeight: FontWeight.w900,
                              color: PaalvandiTheme.textDark,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (collected < sub.pendingBottles) {
                              HapticService.light();
                              setDialogState(() {
                                collected++;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(scaleF(8)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: Icon(Icons.add, size: scaleF(18), color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: scaleF(24)),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticService.light();
                              Navigator.pop(dialogContext);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(12),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: scaleF(12)),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticService.heavy();
                              context.read<SubscriptionsViewModel>().add(
                                CollectSubscriptionBottles(sub.id, collected),
                              );
                              Navigator.pop(dialogContext);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                              decoration: BoxDecoration(
                                color: PaalvandiTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  'Save',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(12),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentCollectionConfirmDialog(BuildContext context, SubscriptionDeliveryModel sub, Function scaleF, Function fs) {
    HapticService.medium();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(scaleF(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.monetization_on_outlined,
                  size: scaleF(40),
                  color: PaalvandiTheme.statusWarning,
                ),
                SizedBox(height: scaleF(16)),
                Text(
                  'Collect Pending Cash?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.bold,
                    color: PaalvandiTheme.deliveredGreen, // Green heading
                  ),
                ),
                SizedBox(height: scaleF(8)),
                Text(
                  'Have you collected ₹${sub.balanceAmount.toStringAsFixed(0)} pending amount from ${sub.customerName}?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(11),
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
                SizedBox(height: scaleF(24)),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticService.light();
                          Navigator.pop(dialogContext);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'No, Go Back',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: scaleF(12)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticService.heavy();
                          Navigator.pop(dialogContext);
                          _showDeliverConfirmDialog(context, sub, scaleF, fs);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                          decoration: BoxDecoration(
                            color: PaalvandiTheme.statusWarning,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'Yes, Collected',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeliverConfirmDialog(BuildContext context, SubscriptionDeliveryModel sub, Function scaleF, Function fs) {
    HapticService.medium();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(scaleF(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: scaleF(40),
                  color: PaalvandiTheme.statusSuccess,
                ),
                SizedBox(height: scaleF(16)),
                Text(
                  'Confirm Delivery?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.bold,
                    color: PaalvandiTheme.deliveredGreen, // Green heading
                  ),
                ),
                SizedBox(height: scaleF(8)),
                Text(
                  'Mark delivery for ${sub.customerName} as delivered?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(11),
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
                SizedBox(height: scaleF(24)),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticService.light();
                          Navigator.pop(dialogContext);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: scaleF(12)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticService.heavy();
                          context.read<SubscriptionsViewModel>().add(MarkSubscriptionDelivered(sub.id));
                          Navigator.pop(dialogContext);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                          decoration: BoxDecoration(
                            color: PaalvandiTheme.statusSuccess,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'Yes, Deliver',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFinishRouteConfirmDialog(BuildContext context, Function scaleF, Function fs) {
    HapticService.medium();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(scaleF(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: scaleF(40),
                  color: PaalvandiTheme.accentGreen,
                ),
                SizedBox(height: scaleF(16)),
                Text(
                  'Finish Route?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.bold,
                    color: PaalvandiTheme.deliveredGreen, // Green heading
                  ),
                ),
                SizedBox(height: scaleF(8)),
                Text(
                  'Are you sure you want to finish this route? This will submit your progress.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(11),
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
                SizedBox(height: scaleF(24)),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticService.light();
                          Navigator.pop(dialogContext);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: scaleF(12)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticService.heavy();
                          context.read<SubscriptionsViewModel>().add(FinishRoute(widget.routeName));
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Route ${widget.routeName} finished successfully!',
                                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: PaalvandiTheme.statusSuccess,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                          decoration: BoxDecoration(
                            color: PaalvandiTheme.accentGreen,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'Yes, Finish',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
    final scaleF =
        (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs =
        (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: PaalvandiTheme.bgCream,
      appBar: AppBar(
        backgroundColor: PaalvandiTheme.bgCream,
        title: Text(
          widget.routeName,
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
          final allRouteSubs = state.subscriptions.where((s) => s.routeName == widget.routeName).toList();
          final activeSubs = allRouteSubs.where((s) => s.status == 'Active').toList();
          final inactiveSubs = allRouteSubs.where((s) => s.status == 'Paused' || s.status == 'Vacation Mode').toList();

          final totalActive = activeSubs.length;
          final completedActive = activeSubs.where((s) => s.isDelivered || s.isSkipped).length;
          final isRouteFinished = totalActive > 0 && completedActive == totalActive;
          final routeStatus = state.routeStatuses[widget.routeName] ?? 'Not Started';
          final isRouteCompletedInState = routeStatus == 'Completed';

          return Column(
            children: [
              // Route Progress Banner
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(8)),
                padding: EdgeInsets.all(scaleF(12)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route Progress',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            fontWeight: FontWeight.bold,
                            color: PaalvandiTheme.deliveredGreen, // Green Heading
                          ),
                        ),
                        SizedBox(height: scaleF(2)),
                        Text(
                          '$completedActive of $totalActive Customers Done',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(13),
                            fontWeight: FontWeight.bold,
                            color: PaalvandiTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(4)),
                      decoration: BoxDecoration(
                        color: isRouteCompletedInState ? const Color(0xFFE8F5E9) : PaalvandiTheme.bgLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Text(
                        isRouteCompletedInState ? 'Completed' : (isRouteFinished ? 'Ready to Finish' : 'In Progress'),
                        style: GoogleFonts.montserrat(
                          fontSize: fs(9),
                          fontWeight: FontWeight.bold,
                          color: isRouteCompletedInState ? PaalvandiTheme.statusSuccess : PaalvandiTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Customer lists
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(8)),
                  children: [
                    // Active list
                    if (activeSubs.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.only(bottom: scaleF(8), top: scaleF(8)),
                        child: Text(
                          'Active Customers (${activeSubs.length})',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: FontWeight.bold,
                            color: PaalvandiTheme.deliveredGreen, // Green Heading
                          ),
                        ),
                      ),
                      ...activeSubs.map((sub) => _buildCustomerCard(sub, scaleF, fs)),
                    ],

                    // Paused / Vacation list
                    if (inactiveSubs.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.only(bottom: scaleF(8), top: scaleF(16)),
                        child: Text(
                          'Vacation & Paused Customers (${inactiveSubs.length})',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: FontWeight.bold,
                            color: PaalvandiTheme.deliveredGreen, // Green Heading
                          ),
                        ),
                      ),
                      ...inactiveSubs.map((sub) => _buildInactiveCustomerCard(sub, scaleF, fs)),
                    ],
                    SizedBox(height: scaleF(80)),
                  ],
                ),
              ),

              // Finish Route Bottom Sticky Panel
              Container(
                padding: EdgeInsets.all(hPadding),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black, width: 1.5)),
                ),
                child: SafeArea(
                  top: false,
                  child: isRouteCompletedInState
                      ? Container(
                          padding: EdgeInsets.symmetric(vertical: scaleF(14)),
                          decoration: BoxDecoration(
                            color: PaalvandiTheme.accentGreen.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'Route Completed',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: fs(14),
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: isRouteFinished
                              ? () => _showFinishRouteConfirmDialog(context, scaleF, fs)
                              : () {
                                  HapticService.medium();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please process all active customers before finishing the route.',
                                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                                      ),
                                      backgroundColor: PaalvandiTheme.statusWarning,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: scaleF(14)),
                            decoration: BoxDecoration(
                              color: isRouteFinished ? PaalvandiTheme.accentGreen : PaalvandiTheme.bgLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                'Finish Route',
                                style: GoogleFonts.montserrat(
                                  color: isRouteFinished ? Colors.white : PaalvandiTheme.textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fs(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomerCard(SubscriptionDeliveryModel sub, Function scaleF, Function fs) {
    Color cardColor = Colors.white;
    if (sub.isDelivered) {
      cardColor = const Color(0xFFE3F2FD); // Light Blue for Delivered
    } else if (sub.isSkipped) {
      cardColor = const Color(0xFFFFEBEE); // Light Red for Skipped
    }

    final products = <String>[];
    if (sub.quantity.contains('Milk')) products.add('Milk');
    if (sub.quantity.contains('Curd')) products.add('Curd');
    if (sub.quantity.contains('Buttermilk')) products.add('Buttermilk');
    if (products.isEmpty) products.add('Milk');

    return Container(
      margin: EdgeInsets.only(bottom: scaleF(12)),
      padding: EdgeInsets.all(scaleF(16)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${sub.subscriptionType} Subscription',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(12),
                      fontWeight: FontWeight.w900,
                      color: PaalvandiTheme.textDark,
                    ),
                  ),
                  SizedBox(width: scaleF(8)),
                  GestureDetector(
                    onTap: () {
                      HapticService.light();
                      context.push('/subscriptions/billing-details/${sub.id}');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: scaleF(6), vertical: scaleF(3)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: scaleF(10), color: Colors.black),
                          SizedBox(width: scaleF(4)),
                          Text(
                            'Bill & Ledger',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(8),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (sub.isDelivered)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(3)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Text(
                    'Delivered',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(9),
                      color: PaalvandiTheme.deliveredGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (sub.isSkipped)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(3)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Text(
                    'Skipped',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(9),
                      color: PaalvandiTheme.statusError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: scaleF(10)),

          // Customer info
          Row(
            children: [
              Icon(Icons.person_outline, size: scaleF(16), color: PaalvandiTheme.primaryBlue),
              SizedBox(width: scaleF(8)),
              Expanded(
                child: Text(
                  '${sub.customerName}  •  +91 ${sub.phone}',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    fontWeight: FontWeight.bold,
                    color: PaalvandiTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(6)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: scaleF(16), color: PaalvandiTheme.primaryBlue),
              SizedBox(width: scaleF(8)),
              Expanded(
                child: Text(
                  sub.address,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(11),
                    color: PaalvandiTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(12)),

          // ─── Inline detailed product images, balance amount, paid amounts ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image(s)
              Row(
                children: products.map((prod) {
                  return Container(
                    margin: EdgeInsets.only(right: scaleF(8)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(
                        _getProductImageUrl(prod),
                        width: scaleF(45),
                        height: scaleF(45),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: scaleF(45),
                          height: scaleF(45),
                          color: PaalvandiTheme.bgLight,
                          child: Icon(Icons.water_drop_outlined, size: scaleF(18), color: PaalvandiTheme.primaryBlue),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(width: scaleF(8)),
              // Payment balance details
              Expanded(
                child: () {
                  double qty = 1.0;
                  final match = RegExp(r'([\d.]+)\s*(L|ml)').firstMatch(sub.quantity);
                  if (match != null) {
                    qty = double.tryParse(match.group(1) ?? '1.0') ?? 1.0;
                    if (match.group(2)?.toLowerCase() == 'ml') {
                      qty /= 1000.0;
                    }
                  }
                  double rate = sub.subscriptionType == 'Business' ? 55.0 : 60.0;
                  if (sub.id == 'SUB-SAI-5') {
                    qty = 50.0; // Event 50L
                  } else if (sub.id == 'SUB-VAD-3') {
                    qty = 20.0;
                  }
                  double totalProductAmount = qty * rate;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.balanceAmount == 0
                            ? 'paid advance or full amount: ₹${sub.paidAmount.toStringAsFixed(0)}'
                            : 'paid advance: ₹${sub.paidAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(10),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.deliveredGreen,
                        ),
                      ),
                      SizedBox(height: scaleF(2)),
                      Text(
                        'total amount of product: ₹${totalProductAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(10),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(4)),
                      
                      // CLEARLY VISIBLE CASH COLLECTION BADGE
                      if (sub.balanceAmount > 0)
                        Container(
                          margin: EdgeInsets.only(top: scaleF(4)),
                          padding: EdgeInsets.symmetric(horizontal: scaleF(10), vertical: scaleF(6)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB74D), // Solid orange/warning
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.currency_rupee, size: scaleF(12), color: Colors.black),
                              SizedBox(width: scaleF(4)),
                              Text(
                                'need to collect this much: ₹${sub.balanceAmount.toStringAsFixed(0)}',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(11),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }(),
              ),
            ],
          ),
          SizedBox(height: scaleF(12)),

          // Product details & bottle badges
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(4)),
                decoration: BoxDecoration(
                  color: PaalvandiTheme.primaryBlue, // Solid blue
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.water_drop_outlined, size: scaleF(12), color: Colors.white),
                    SizedBox(width: scaleF(4)),
                    Text(
                      sub.quantity,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(10),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: scaleF(8)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(4)),
                decoration: BoxDecoration(
                  color: Colors.amber, // Solid amber/yellow
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Text(
                  sub.bottleType,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(10),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          // Pending / Collected Bottles alerts
          if (sub.pendingBottles > 0) ...[
            SizedBox(height: scaleF(8)),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: scaleF(10), vertical: scaleF(6)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE082), // Solid light amber
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wine_bar_outlined, color: Colors.black, size: scaleF(14)),
                        SizedBox(width: scaleF(6)),
                        Expanded(
                          child: Text(
                            sub.bottlesCollected > 0
                                ? 'Collected: ${sub.bottlesCollected} of ${sub.pendingBottles} bottles'
                                : 'Pending empty bottles: ${sub.pendingBottles}',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(10),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!sub.isDelivered && !sub.isSkipped) ...[
                  SizedBox(width: scaleF(8)),
                  GestureDetector(
                    onTap: () => _showBottleCollectionDialog(context, sub, scaleF, fs),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: scaleF(12), vertical: scaleF(8)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Text(
                        'Collect',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(10),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],

          if (sub.isSkipped && sub.skipReason != null) ...[
            SizedBox(height: scaleF(8)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: scaleF(10), vertical: scaleF(6)),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Text(
                'Skip Reason: ${sub.skipReason}',
                style: GoogleFonts.montserrat(
                  fontSize: fs(10),
                  fontWeight: FontWeight.bold,
                  color: PaalvandiTheme.statusError,
                ),
              ),
            ),
          ],

          // Action buttons (Only show if not processed yet)
          if (!sub.isDelivered && !sub.isSkipped) ...[
            SizedBox(height: scaleF(14)),
            Divider(color: PaalvandiTheme.dividerColor, height: 1),
            SizedBox(height: scaleF(12)),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    'Call',
                    Icons.phone_outlined,
                    PaalvandiTheme.accentGreen,
                    () async {
                      HapticService.light();
                      final uri = Uri.parse('tel:${sub.phone}');
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    scaleF,
                    fs,
                  ),
                ),
                SizedBox(width: scaleF(8)),
                Expanded(
                  child: _actionButton(
                    'Navigate',
                    Icons.navigation_outlined,
                    PaalvandiTheme.primaryBlue,
                    () {
                      HapticService.light();
                      final encoded = Uri.encodeComponent(sub.address);
                      launchUrl(
                        Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    scaleF,
                    fs,
                  ),
                ),
                SizedBox(width: scaleF(8)),
                Expanded(
                  child: _actionButton(
                    'Skip',
                    Icons.skip_next_outlined,
                    PaalvandiTheme.statusError,
                    () => _showSkipReasonSheet(context, sub, scaleF, fs),
                    scaleF,
                    fs,
                  ),
                ),
                SizedBox(width: scaleF(8)),
                Expanded(
                  child: _actionButton(
                    'Delivered',
                    Icons.check_circle_outline,
                    PaalvandiTheme.statusSuccess,
                    () {
                      if (sub.balanceAmount > 0) {
                        _showPaymentCollectionConfirmDialog(context, sub, scaleF, fs);
                      } else {
                        _showDeliverConfirmDialog(context, sub, scaleF, fs);
                      }
                    },
                    scaleF,
                    fs,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInactiveCustomerCard(SubscriptionDeliveryModel sub, Function scaleF, Function fs) {
    return Container(
      margin: EdgeInsets.only(bottom: scaleF(12)),
      padding: EdgeInsets.all(scaleF(16)),
      decoration: BoxDecoration(
        color: PaalvandiTheme.bgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PaalvandiTheme.textMuted.withOpacity(0.3), width: 1.5),
      ),
      child: Opacity(
        opacity: 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${sub.subscriptionType} Subscription',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textSecondary,
                      ),
                    ),
                    SizedBox(width: scaleF(8)),
                    GestureDetector(
                      onTap: () {
                        HapticService.light();
                        context.push('/subscriptions/billing-details/${sub.id}');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: scaleF(6), vertical: scaleF(3)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: scaleF(10), color: Colors.black),
                            SizedBox(width: scaleF(4)),
                            Text(
                              'Bill & Ledger',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(8),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(3)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Text(
                    sub.status,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(9),
                      color: PaalvandiTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleF(10)),
            Text(
              sub.customerName,
              style: GoogleFonts.montserrat(
                fontSize: fs(12),
                fontWeight: FontWeight.bold,
                color: PaalvandiTheme.textDark,
              ),
            ),
            SizedBox(height: scaleF(4)),
            Text(
              sub.address,
              style: GoogleFonts.montserrat(
                fontSize: fs(11),
                color: PaalvandiTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap, Function scaleF, Function fs) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: scaleF(10)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: scaleF(18)),
            SizedBox(height: scaleF(4)),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: fs(9),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
