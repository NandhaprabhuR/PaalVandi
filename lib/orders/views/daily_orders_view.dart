import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../models/daily_order_model.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/services/haptic_service.dart';

class DailyOrdersView extends StatefulWidget {
  const DailyOrdersView({super.key});

  @override
  State<DailyOrdersView> createState() => _DailyOrdersViewState();
}

class _DailyOrdersViewState extends State<DailyOrdersView> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersViewModel>().add(const LoadOrders());
  }

  Color _paymentColor(String status) {
    switch (status) {
      case 'Paid':
        return PaalvandiTheme.statusSuccess;
      case 'Pay At Delivery':
        return PaalvandiTheme.statusWarning;
      default:
        return PaalvandiTheme.statusPending;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return PaalvandiTheme.deliveredGreen;
      case 'Accepted':
        return PaalvandiTheme.assignedBlue;
      case 'Cancelled':
        return PaalvandiTheme.statusError;
      case 'Assigned':
      default:
        return PaalvandiTheme.preparingAmber;
    }
  }

  void _showCancelOrderBottomSheet(
    BuildContext context,
    DailyOrderModel order,
    Function scaleF,
    Function fs,
  ) {
    HapticService.medium();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: PaalvandiTheme.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.all(scaleF(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cancel Order',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(18),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
                SizedBox(height: scaleF(16)),
                Text(
                  'Please provide a reason for cancelling this order:',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
                SizedBox(height: scaleF(12)),
                TextField(
                  maxLines: 3,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter reason here...',
                    hintStyle: GoogleFonts.montserrat(
                      fontSize: fs(12),
                      color: PaalvandiTheme.textMuted,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PaalvandiTheme.cardBorder, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PaalvandiTheme.primaryBlue, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: scaleF(24)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PaalvandiTheme.statusError,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: scaleF(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      HapticService.heavy();
                      context.read<OrdersViewModel>().add(UpdateOrderStatus(order.orderId, 'Cancelled'));
                      Navigator.pop(bottomSheetContext);
                    },
                    child: Text(
                      'Confirm Cancellation',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStatusConfirmDialog(
    BuildContext context,
    DailyOrderModel order,
    String newStatus,
    String actionLabel,
    Color actionColor,
    Function scaleF,
    Function fs,
  ) {
    if (newStatus == 'Cancelled') {
      _showCancelOrderBottomSheet(context, order, scaleF, fs);
      return;
    }
    
    HapticService.medium();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: PaalvandiTheme.cardBorder, width: 2),
          ),
          backgroundColor: PaalvandiTheme.bgCream,
          child: Padding(
            padding: EdgeInsets.all(scaleF(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: scaleF(40),
                  color: actionColor,
                ),
                SizedBox(height: scaleF(16)),
                Text(
                  '$actionLabel this order?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.bold,
                    color: PaalvandiTheme.textDark,
                  ),
                ),
                SizedBox(height: scaleF(8)),
                Text(
                  'Confirming will set the order status to Accepted.',
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
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PaalvandiTheme.textDark,
                          side: const BorderSide(color: PaalvandiTheme.cardBorder, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: scaleF(10)),
                        ),
                        onPressed: () {
                          HapticService.light();
                          Navigator.pop(dialogContext);
                        },
                        child: Text(
                          'No',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: fs(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: scaleF(12)),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: scaleF(10)),
                        ),
                        onPressed: () {
                          HapticService.heavy();
                          context.read<OrdersViewModel>().add(UpdateOrderStatus(order.orderId, newStatus));
                          Navigator.pop(dialogContext);
                        },
                        child: Text(
                          'Yes, $actionLabel',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: fs(12),
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

    return BlocConsumer<OrdersViewModel, OrdersState>(
      listener: (context, state) {
        if (state.deliveredOrderId != null) {
          HapticService.heavy();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Order ${state.deliveredOrderId} delivered successfully!',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
              backgroundColor: PaalvandiTheme.statusSuccess,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: PaalvandiTheme.bgCream,
            appBar: _buildAppBar(context, fs),
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

        // Segment orders based on tab type
        final assignedOrders = state.orders.where((o) => o.status == 'Assigned').toList();
        final acceptedOrders = state.orders.where((o) => o.status == 'Accepted').toList();
        final cancelledOrders = state.orders.where((o) => o.status == 'Cancelled').toList();

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: PaalvandiTheme.bgCream,
            appBar: _buildAppBar(context, fs),
            body: Column(
              children: [
                Container(
                  color: PaalvandiTheme.cardWhite,
                  width: double.infinity,
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: PaalvandiTheme.primaryBlue,
                        indicatorWeight: 3.0,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: PaalvandiTheme.primaryBlue,
                        unselectedLabelColor: PaalvandiTheme.textSecondary,
                        labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: fs(11),
                        ),
                        unselectedLabelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: fs(11),
                        ),
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(text: 'New (${assignedOrders.length})'),
                          Tab(text: 'Accepted (${acceptedOrders.length})'),
                          Tab(text: 'Rejected (${cancelledOrders.length})'),
                        ],
                      ),
                      Container(
                        height: 1.0,
                        color: PaalvandiTheme.cardBorder,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildOrdersList(context, assignedOrders, scaleF, fs, hPadding, 'No new orders assigned'),
                      _buildOrdersList(context, acceptedOrders, scaleF, fs, hPadding, 'No active accepted orders'),
                      _buildOrdersList(context, cancelledOrders, scaleF, fs, hPadding, 'No rejected orders'),
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

  PreferredSizeWidget _buildAppBar(BuildContext context, Function fs) {
    return AppBar(
      backgroundColor: PaalvandiTheme.bgCream,
      elevation: 0,
      title: Text('Daily Orders',
          style: GoogleFonts.montserrat(
              fontSize: fs(18),
              fontWeight: FontWeight.bold,
              color: PaalvandiTheme.textDark)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: PaalvandiTheme.textDark),
          tooltip: 'Delivery History',
          onPressed: () {
            HapticService.light();
            context.push('/orders/history');
          },
        ),
      ],
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    List<DailyOrderModel> list,
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
            Lottie.asset('assets/animations/noitemincart.json',
                height: scaleF(120)),
            SizedBox(height: scaleF(16)),
            Text(
              emptyMessage,
              style: GoogleFonts.montserrat(
                fontSize: fs(14),
                fontWeight: FontWeight.bold,
                color: PaalvandiTheme.textSecondary,
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
        return _buildOrderCard(context, list[index], scaleF, fs);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, DailyOrderModel order,
      Function scaleF, Function fs) {
    Color cardBgColor;
    if (order.status == 'Accepted') {
      cardBgColor = const Color(0xFFE8F5E9); // Light Green
    } else if (order.status == 'Cancelled' || order.status == 'Rejected') {
      cardBgColor = const Color(0xFFFFEBEE); // Light Red
    } else if (order.status == 'Delivered') {
      cardBgColor = const Color(0xFFE3F2FD); // Light Blue
    } else {
      cardBgColor = Colors.white; // New orders (Assigned)
    }

    return GestureDetector(
      onTap: () {
        HapticService.light();
        context.push('/order-detail/${order.orderId}');
      },
      child: Container(
        padding: EdgeInsets.all(scaleF(16)),
        decoration: PaalvandiTheme.cardDecoration.copyWith(
          color: cardBgColor,
          border: Border.all(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Order ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.orderId} • ${order.orderTime.hour.toString().padLeft(2, '0')}:${order.orderTime.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.w900,
                    color: PaalvandiTheme.textDark,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: scaleF(10), vertical: scaleF(4)),
                  decoration:
                      PaalvandiTheme.statusBadgeDecoration(_statusColor(order.status)),
                  child: Text(
                    order.status == 'Assigned' ? 'Assigned' : (order.status == 'Accepted' ? 'Accepted' : 'Rejected'),
                    style: GoogleFonts.montserrat(
                      fontSize: fs(10),
                      fontWeight: FontWeight.bold,
                      color: _statusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleF(12)),

            // Customer Info
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: scaleF(16), color: PaalvandiTheme.primaryBlue),
                SizedBox(width: scaleF(8)),
                Expanded(
                  child: Text(
                    '${order.customerName}  •  +91 ${order.customerPhone}',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(12),
                      fontWeight: FontWeight.w600,
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
                Icon(Icons.location_on_outlined,
                    size: scaleF(16), color: PaalvandiTheme.primaryBlue),
                SizedBox(width: scaleF(8)),
                Expanded(
                  child: Text(
                    order.address,
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

            // Products
            ...order.products.map((p) => Padding(
                  padding: EdgeInsets.only(bottom: scaleF(4)),
                  child: Row(
                    children: [
                      Icon(Icons.circle,
                          size: scaleF(6), color: PaalvandiTheme.primaryBlue),
                      SizedBox(width: scaleF(8)),
                      Text(
                        '${p.name} (${p.unit}) × ${p.quantity}',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(11),
                          fontWeight: FontWeight.w500,
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                )),
            SizedBox(height: scaleF(8)),

            // Delivery Type + Bottle Deposits + Payment Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: scaleF(6),
                    runSpacing: scaleF(6),
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: scaleF(8), vertical: scaleF(3)),
                        decoration: PaalvandiTheme.statusBadgeDecoration(
                            PaalvandiTheme.primaryBlue),
                        child: Text(
                          order.deliveryType,
                          style: GoogleFonts.montserrat(
                            fontSize: fs(9),
                            fontWeight: FontWeight.bold,
                            color: PaalvandiTheme.primaryBlue,
                          ),
                        ),
                      ),
                      if (order.bottleDepositAmount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: scaleF(8), vertical: scaleF(3)),
                          decoration: PaalvandiTheme.statusBadgeDecoration(
                              PaalvandiTheme.statusPending),
                          child: Text(
                            'Deposit: ₹${order.bottleDepositAmount.toStringAsFixed(0)}',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(9),
                              fontWeight: FontWeight.bold,
                              color: PaalvandiTheme.statusPending,
                            ),
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: scaleF(8), vertical: scaleF(3)),
                        decoration: PaalvandiTheme.statusBadgeDecoration(
                            _paymentColor(order.paymentStatus)),
                        child: Text(
                          '${order.paymentMethod} (${order.paymentStatus})',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(9),
                            fontWeight: FontWeight.bold,
                            color: _paymentColor(order.paymentStatus),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: scaleF(12)),
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

            SizedBox(height: scaleF(14)),
            Divider(color: PaalvandiTheme.dividerColor, height: 1),
            SizedBox(height: scaleF(12)),

            // Solid Colored Action Buttons (unified with other page designs)
            if (order.status == 'Assigned') ...[
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      'Cancel Order',
                      Icons.cancel_outlined,
                      PaalvandiTheme.statusError,
                      () => _showStatusConfirmDialog(context, order, 'Cancelled', 'Cancel', PaalvandiTheme.statusError, scaleF, fs),
                      scaleF,
                      fs,
                    ),
                  ),
                  SizedBox(width: scaleF(8)),
                  Expanded(
                    child: _actionButton(
                      'Accept Order',
                      Icons.check_circle_outline,
                      PaalvandiTheme.accentGreen,
                      () {
                        final hasActiveAccepted = context.read<OrdersViewModel>().state.orders.any((o) => o.status == 'Accepted');
                        if (hasActiveAccepted) {
                          HapticService.heavy();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You can only accept one order at a time. Please complete or cancel your current active order first!',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: PaalvandiTheme.statusError,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        } else {
                          _showStatusConfirmDialog(context, order, 'Accepted', 'Accept', PaalvandiTheme.accentGreen, scaleF, fs);
                        }
                      },
                      scaleF,
                      fs,
                    ),
                  ),
                ],
              ),
            ] else if (order.status == 'Accepted') ...[
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      'Call',
                      Icons.phone_outlined,
                      PaalvandiTheme.accentGreen,
                      () async {
                        HapticService.light();
                        final uri = Uri.parse('tel:${order.customerPhone}');
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
                        final encoded = Uri.encodeComponent(order.address);
                        launchUrl(
                            Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded'),
                            mode: LaunchMode.externalApplication);
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
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color,
      VoidCallback onTap, Function scaleF, Function fs) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: scaleF(12)),
        decoration: BoxDecoration(
          color: color, // Solid Color Fill
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: scaleF(16)),
            SizedBox(width: scaleF(6)),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: fs(11),
                fontWeight: FontWeight.bold,
                color: Colors.white, // White Text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
