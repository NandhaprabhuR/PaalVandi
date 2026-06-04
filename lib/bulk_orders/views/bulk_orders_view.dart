import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import '../viewmodels/bulk_viewmodel.dart';
import '../models/bulk_order_model.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/services/haptic_service.dart';
import '../../core/widgets/image_carousel_dialog.dart';

class BulkOrdersView extends StatefulWidget {
  const BulkOrdersView({super.key});

  @override
  State<BulkOrdersView> createState() => _BulkOrdersViewState();
}

class _BulkOrdersViewState extends State<BulkOrdersView> {
  @override
  void initState() {
    super.initState();
    context.read<BulkViewModel>().add(const LoadBulkOrders());
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Hotel':
        return PaalvandiTheme.primaryBlue;
      case 'Event':
        return PaalvandiTheme.statusPending;
      case 'Business':
        return PaalvandiTheme.deliveredGreen;
      default:
        return PaalvandiTheme.textSecondary;
    }
  }

  Color _typeCardColor(String type) {
    switch (type) {
      case 'Hotel':
        return const Color(0xFFE3F2FD);
      case 'Event':
        return const Color(0xFFFFF8E1);
      case 'Business':
        return const Color(0xFFE8F5E9);
      default:
        return Colors.white;
    }
  }

  String _getProductImageByName(String name) {
    name = name.toLowerCase();
    if (name.contains('curd')) {
      return 'https://images.unsplash.com/photo-1628045958619-3c996611c0ed?auto=format&fit=crop&q=80&w=200'; // Curd
    } else if (name.contains('buttermilk') || name.contains('moor')) {
      return 'https://images.unsplash.com/photo-1596181775878-57790b8fcf32?auto=format&fit=crop&q=80&w=200'; // Buttermilk
    }
    // Default Milk
    return 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&q=80&w=200';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ─── Delivery Confirmation Bottom Sheet ───────────────────────
  void _showDeliveryConfirmationSheet(
    BuildContext context,
    BulkOrderModel order,
    Function scaleF,
    Function fs,
  ) {
    final otpController = TextEditingController();
    final double advancePaid = 500.0;
    final double toCollect = (order.totalAmount - advancePaid).clamp(
      0,
      double.infinity,
    );
    final formKey = GlobalKey<FormState>();

    // State variables for Yes/No selection and queries
    bool? hasCollectedBalance; // null = not selected, true = yes, false = no
    bool showQueriesInput = false;
    final queriesAmountController = TextEditingController();

    HapticService.medium();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Colors.black, width: 2),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bool isPaidOnline =
                order.paymentStatus == 'Paid' ||
                order.paymentStatus == 'Paid Fully';
            final bool isOtpValid = otpController.text.length == 4;
            final bool isBalanceAnswered =
                isPaidOnline || hasCollectedBalance != null;
            final bool canSubmit = isOtpValid && isBalanceAnswered;

            return Padding(
              padding: EdgeInsets.only(
                left: scaleF(20),
                right: scaleF(20),
                top: scaleF(16),
                bottom:
                    MediaQuery.of(sheetContext).viewInsets.bottom + scaleF(24),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
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

                      // Title
                      Text(
                        'Confirm Delivery',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(16),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.deliveredGreen,
                        ),
                      ),
                      SizedBox(height: scaleF(4)),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            color: PaalvandiTheme.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'Enter verification OTP for '),
                            TextSpan(
                              text: order.businessName,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: PaalvandiTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: scaleF(20)),

                      // Order summary
                      Container(
                        padding: EdgeInsets.all(scaleF(12)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: isPaidOnline
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: isPaidOnline
                                  ? CrossAxisAlignment.center
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(9),
                                    fontWeight: FontWeight.bold,
                                    color: PaalvandiTheme.textMuted,
                                  ),
                                ),
                                Text(
                                  '₹${order.totalAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(16),
                                    fontWeight: FontWeight.w900,
                                    color: PaalvandiTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                            if (!isPaidOnline) ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Advance Paid',
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(9),
                                      fontWeight: FontWeight.bold,
                                      color: PaalvandiTheme.textMuted,
                                    ),
                                  ),
                                  Text(
                                    '₹${advancePaid.toStringAsFixed(0)}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(16),
                                      fontWeight: FontWeight.w900,
                                      color: PaalvandiTheme.deliveredGreen,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'To Collect',
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(9),
                                      fontWeight: FontWeight.bold,
                                      color: PaalvandiTheme.textMuted,
                                    ),
                                  ),
                                  Text(
                                    '₹${toCollect.toStringAsFixed(0)}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(16),
                                      fontWeight: FontWeight.w900,
                                      color: PaalvandiTheme.statusWarning,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: scaleF(20)),

                      // OTP Field
                      Text(
                        'Verification OTP',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(11),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(8)),
                      TextFormField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        onChanged: (_) => setSheetState(() {}),
                        style: GoogleFonts.montserrat(
                          fontSize: fs(16),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '• • • •',
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: fs(16),
                            color: PaalvandiTheme.textMuted,
                            letterSpacing: 8,
                          ),
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: scaleF(14),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: PaalvandiTheme.primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter OTP';
                          }
                          if (value.length != 4) {
                            return 'OTP must be 4 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: scaleF(20)),

                      if (!isPaidOnline) ...[
                        // ─── Balance Collection Yes/No ───
                        Text(
                          'Have you collected the balance amount ₹${toCollect.toStringAsFixed(0)}?',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: FontWeight.bold,
                            color: PaalvandiTheme.textDark,
                          ),
                        ),
                        SizedBox(height: scaleF(10)),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticService.light();
                                  setSheetState(() {
                                    hasCollectedBalance = true;
                                    showQueriesInput = false;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: scaleF(12),
                                  ),
                                  decoration: BoxDecoration(
                                    color: hasCollectedBalance == true
                                        ? PaalvandiTheme.statusSuccess
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: hasCollectedBalance == true
                                          ? PaalvandiTheme.statusSuccess
                                          : Colors.black,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Yes, Collected',
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(12),
                                        fontWeight: FontWeight.bold,
                                        color: hasCollectedBalance == true
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: scaleF(10)),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticService.light();
                                  setSheetState(() {
                                    hasCollectedBalance = false;
                                    showQueriesInput = false;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: scaleF(12),
                                  ),
                                  decoration: BoxDecoration(
                                    color: hasCollectedBalance == false
                                        ? PaalvandiTheme.statusError
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: hasCollectedBalance == false
                                          ? PaalvandiTheme.statusError
                                          : Colors.black,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No',
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(12),
                                        fontWeight: FontWeight.bold,
                                        color: hasCollectedBalance == false
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ─── Queries Button (optional partial payment) ───
                        if (hasCollectedBalance != null) ...[
                          SizedBox(height: scaleF(12)),
                          GestureDetector(
                            onTap: () {
                              HapticService.light();
                              setSheetState(() {
                                showQueriesInput = !showQueriesInput;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: scaleF(12),
                                vertical: scaleF(8),
                              ),
                              decoration: BoxDecoration(
                                color: showQueriesInput
                                    ? PaalvandiTheme.primaryBlue
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.help_outline,
                                    size: scaleF(14),
                                    color: showQueriesInput
                                        ? Colors.white
                                        : PaalvandiTheme.textSecondary,
                                  ),
                                  SizedBox(width: scaleF(6)),
                                  Text(
                                    'Queries (partial payment)',
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(10),
                                      fontWeight: FontWeight.bold,
                                      color: showQueriesInput
                                          ? Colors.white
                                          : PaalvandiTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // ─── Queries Amount Input (optional) ───
                        if (showQueriesInput) ...[
                          SizedBox(height: scaleF(12)),
                          Text(
                            'How much amount have you collected? (optional)',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(11),
                              fontWeight: FontWeight.bold,
                              color: PaalvandiTheme.textDark,
                            ),
                          ),
                          SizedBox(height: scaleF(8)),
                          TextFormField(
                            controller: queriesAmountController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(14),
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              prefixText: '₹ ',
                              prefixStyle: GoogleFonts.montserrat(
                                fontSize: fs(14),
                                fontWeight: FontWeight.bold,
                                color: PaalvandiTheme.textDark,
                              ),
                              hintText: 'Enter amount collected',
                              hintStyle: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                color: PaalvandiTheme.textMuted,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: scaleF(16),
                                vertical: scaleF(14),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: PaalvandiTheme.primaryBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],

                      SizedBox(height: scaleF(24)),

                      // Confirm Button — disabled until OTP + Yes/No selected
                      GestureDetector(
                        onTap: canSubmit
                            ? () {
                                if (formKey.currentState!.validate()) {
                                  HapticService.heavy();
                                  final double? collectedAmt = double.tryParse(
                                    queriesAmountController.text,
                                  );
                                  context.read<BulkViewModel>().add(
                                    MarkBulkDelivered(
                                      id: order.id,
                                      hasCollectedBalance:
                                          hasCollectedBalance ?? false,
                                      collectedAmount: collectedAmt,
                                    ),
                                  );
                                  Navigator.pop(sheetContext);
                                }
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: scaleF(14)),
                          decoration: BoxDecoration(
                            color: canSubmit
                                ? PaalvandiTheme.statusSuccess
                                : PaalvandiTheme.bgLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: canSubmit
                                  ? Colors.black
                                  : PaalvandiTheme.dividerColor,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Confirm Delivery',
                              style: GoogleFonts.montserrat(
                                color: canSubmit
                                    ? Colors.white
                                    : PaalvandiTheme.textMuted,
                                fontWeight: FontWeight.bold,
                                fontSize: fs(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double scaleF(num val) =>
        ResponsiveHelper.scaledValue(context, val.toDouble());
    double fs(num size) =>
        ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return BlocConsumer<BulkViewModel, BulkState>(
      listener: (context, state) {
        if (state.deliveredId != null) {
          HapticService.heavy();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Bulk order ${state.deliveredId} delivered successfully!',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: PaalvandiTheme.statusSuccess,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: PaalvandiTheme.bgCream,
            appBar: _buildAppBar(fs),
            body: ListView.builder(
              padding: EdgeInsets.all(hPadding),
              itemCount: 3,
              itemBuilder: (_, __) => Padding(
                padding: EdgeInsets.only(bottom: scaleF(12)),
                child: const SkeletonCard(),
              ),
            ),
          );
        }

        // Segment orders into tabs
        final pendingOrders = state.orders
            .where((o) => !o.isDelivered)
            .toList();
        final deliveredOrders = state.orders
            .where((o) => o.isDelivered)
            .toList();
        // Cancelled orders — currently model doesn't track cancelled, so empty for now
        final cancelledOrders = <BulkOrderModel>[];

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: PaalvandiTheme.bgCream,
            appBar: _buildAppBar(fs),
            body: Column(
              children: [
                // ─── Tab Bar ───
                Container(
                  color: PaalvandiTheme.cardWhite,
                  width: double.infinity,
                  child: Column(
                    children: [
                      TabBar(
                        onTap: (_) => HapticService.light(),
                        indicatorColor: PaalvandiTheme.primaryBlue,
                        indicatorWeight: 3.0,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: PaalvandiTheme.primaryBlue,
                        unselectedLabelColor: PaalvandiTheme.textSecondary,
                        labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: fs(12),
                        ),
                        unselectedLabelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: fs(12),
                        ),
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(text: 'Orders (${pendingOrders.length})'),
                          Tab(text: 'Delivered (${deliveredOrders.length})'),
                          Tab(text: 'Cancelled (${cancelledOrders.length})'),
                        ],
                      ),
                      Container(height: 1.0, color: PaalvandiTheme.cardBorder),
                    ],
                  ),
                ),

                // ─── Tab Bar View ───
                Expanded(
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildOrdersList(
                        context,
                        pendingOrders,
                        scaleF,
                        fs,
                        hPadding,
                        'No pending bulk orders',
                      ),
                      _buildOrdersList(
                        context,
                        deliveredOrders,
                        scaleF,
                        fs,
                        hPadding,
                        'No delivered bulk orders yet',
                      ),
                      _buildOrdersList(
                        context,
                        cancelledOrders,
                        scaleF,
                        fs,
                        hPadding,
                        'No cancelled bulk orders',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(Function fs) {
    return AppBar(
      backgroundColor: PaalvandiTheme.bgCream,
      elevation: 0,
      title: Text(
        'Bulk Orders',
        style: GoogleFonts.montserrat(
          fontSize: fs(18),
          fontWeight: FontWeight.bold,
          color: PaalvandiTheme.deliveredGreen,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: PaalvandiTheme.textDark),
          tooltip: 'Bulk Orders History',
          onPressed: () {
            HapticService.light();
            context.push('/bulk-orders/history');
          },
        ),
      ],
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    List<BulkOrderModel> list,
    Function scaleF,
    Function fs,
    double hPadding,
    String emptyMessage,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/noitemincart.json',
              height: scaleF(120),
            ),
            SizedBox(height: scaleF(16)),
            Text(
              emptyMessage,
              style: GoogleFonts.montserrat(
                fontSize: fs(14),
                fontWeight: FontWeight.bold,
                color: PaalvandiTheme.textDark,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
      itemCount: list.length,
      separatorBuilder: (_, __) => SizedBox(height: scaleF(12)),
      itemBuilder: (context, index) {
        return _buildBulkCard(context, list[index], scaleF, fs);
      },
    );
  }

  Widget _buildBulkCard(
    BuildContext context,
    BulkOrderModel order,
    Function scaleF,
    Function fs,
  ) {
    final isDone = order.isDelivered;
    final double advancePaid = 500.0;
    final double toCollect = (order.totalAmount - advancePaid).clamp(
      0,
      double.infinity,
    );
    final bool isPaidFully =
        order.paymentStatus == 'Paid' || order.paymentStatus == 'Paid Fully';
    final bool isPartiallyPaid = order.paymentStatus == 'Partially Paid';
    final double remainingAmount = isPartiallyPaid
        ? (order.totalAmount - order.collectedAmount).clamp(0, double.infinity)
        : 0;

    final cardColor = isDone
        ? const Color(0xFFE8F5E9)
        : _typeCardColor(order.orderType);

    return Container(
      padding: EdgeInsets.all(scaleF(16)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Business Name & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  HapticService.light();
                  showDialog(
                    context: context,
                    builder: (context) => ImageCarouselDialog(
                      title: order.businessName,
                      imageUrls: const [
                        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
                        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
                        'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=800&q=80',
                      ],
                    ),
                  );
                },
                child: Container(
                  width: scaleF(32),
                  height: scaleF(32),
                  margin: EdgeInsets.only(right: scaleF(10)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=100&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  order.businessName,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.w900,
                    color: PaalvandiTheme.deliveredGreen,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scaleF(8),
                  vertical: scaleF(4),
                ),
                decoration: BoxDecoration(
                  color: isDone
                      ? PaalvandiTheme.statusSuccess
                      : _typeColor(order.orderType),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Text(
                  isDone ? 'DELIVERED' : order.orderType.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: fs(8),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(10)),

          // Order Type and Contact
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contact: ${order.contactPerson}',
                style: GoogleFonts.montserrat(
                  fontSize: fs(11),
                  fontWeight: FontWeight.w600,
                  color: PaalvandiTheme.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(3)),
          Text(
            'Phone: +91 ${order.phone}',
            style: GoogleFonts.montserrat(
              fontSize: fs(10),
              fontWeight: FontWeight.w500,
              color: PaalvandiTheme.textSecondary,
            ),
          ),
          SizedBox(height: scaleF(10)),

          // ─── Products List ───
          Column(
            children: order.productDetails.split('+').map((prod) {
              String productTrimmed = prod.trim();
              return Padding(
                padding: EdgeInsets.only(bottom: scaleF(8)),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.network(
                          _getProductImageByName(productTrimmed),
                          width: scaleF(45),
                          height: scaleF(45),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: scaleF(45),
                                height: scaleF(45),
                                color: PaalvandiTheme.bgLight,
                                child: Icon(
                                  Icons.water_drop_outlined,
                                  size: scaleF(18),
                                  color: PaalvandiTheme.primaryBlue,
                                ),
                              ),
                        ),
                      ),
                    ),
                    SizedBox(width: scaleF(10)),
                    Expanded(
                      child: Text(
                        productTrimmed,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          fontWeight: FontWeight.w700,
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: scaleF(16),
                color: PaalvandiTheme.primaryBlue,
              ),
              SizedBox(width: scaleF(8)),
              Expanded(
                child: Text(
                  order.address,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(11),
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (order.specialNotes.isNotEmpty) ...[
            SizedBox(height: scaleF(8)),
            Container(
              padding: EdgeInsets.all(scaleF(8)),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notes,
                    size: scaleF(14),
                    color: PaalvandiTheme.textSecondary,
                  ),
                  SizedBox(width: scaleF(6)),
                  Expanded(
                    child: Text(
                      order.specialNotes,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(10),
                        fontStyle: FontStyle.italic,
                        color: PaalvandiTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: scaleF(12)),
          Divider(color: PaalvandiTheme.dividerColor, height: 1),
          SizedBox(height: scaleF(12)),

          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scaleF(8),
                  vertical: scaleF(4),
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: scaleF(12),
                      color: Colors.black,
                    ),
                    SizedBox(width: scaleF(4)),
                    Text(
                      '${_formatDate(order.deliveryDate ?? DateTime.now())} • ${order.deliveryTime}',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(10),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(8)),
          SizedBox(height: scaleF(12)),
          Divider(color: PaalvandiTheme.dividerColor, height: 1),
          SizedBox(height: scaleF(12)),

          Text(
            'Total Amount: ₹${order.totalAmount.toStringAsFixed(0)}',
            style: GoogleFonts.montserrat(
              fontSize: fs(10),
              fontWeight: FontWeight.bold,
              color: PaalvandiTheme.textDark,
            ),
          ),
          SizedBox(height: scaleF(4)),

          // ─── Paid Fully highlight ───
          if (isDone && isPaidFully) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: scaleF(12),
                vertical: scaleF(8),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: scaleF(16),
                  ),
                  SizedBox(width: scaleF(6)),
                  Text(
                    'PAID FULLY  •  ₹${order.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(11),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ─── Delivered but partial payment ───
          if (isDone && isPartiallyPaid) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: scaleF(12),
                vertical: scaleF(8),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8F00),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    'Delivered: Need to Collect ₹${remainingAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(11),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: scaleF(2)),
                  Text(
                    'Collected: ₹${order.collectedAmount.toStringAsFixed(0)} of ₹${order.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(9),
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ─── Pending order payment info ───
          if (!isDone) ...[
            Text(
              isPaidFully
                  ? 'Paid Fully: ₹${order.totalAmount.toStringAsFixed(0)}'
                  : 'Advance Paid: ₹${advancePaid.toStringAsFixed(0)}',
              style: GoogleFonts.montserrat(
                fontSize: fs(10),
                fontWeight: FontWeight.bold,
                color: PaalvandiTheme.deliveredGreen,
              ),
            ),
            if (!isPaidFully) ...[
              SizedBox(height: scaleF(6)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scaleF(10),
                  vertical: scaleF(6),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB74D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Text(
                  'Need to collect while delivery: ₹${toCollect.toStringAsFixed(0)}',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(10),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ],

          if (!isDone) ...[
            SizedBox(height: scaleF(14)),
            Divider(color: PaalvandiTheme.dividerColor, height: 1),
            SizedBox(height: scaleF(12)),

            // Actions
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    'Call Business',
                    Icons.phone_outlined,
                    PaalvandiTheme.accentGreen,
                    () async {
                      HapticService.light();
                      final uri = Uri.parse('tel:${order.phone}');
                      await launchUrl(
                        uri,
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
                    'Navigate',
                    Icons.navigation_outlined,
                    PaalvandiTheme.primaryBlue,
                    () {
                      HapticService.light();
                      final encoded = Uri.encodeComponent(order.address);
                      launchUrl(
                        Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=$encoded',
                        ),
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
                    'Delivered',
                    Icons.check_circle_outline,
                    PaalvandiTheme.statusSuccess,
                    () {
                      _showDeliveryConfirmationSheet(
                        context,
                        order,
                        scaleF,
                        fs,
                      );
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

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    Function scaleF,
    Function fs,
  ) {
    final isDark = color != PaalvandiTheme.accentGreen && color != Colors.amber;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;

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
            Icon(icon, color: iconColor, size: scaleF(18)),
            SizedBox(height: scaleF(4)),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: fs(9),
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
