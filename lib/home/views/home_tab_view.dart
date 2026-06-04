import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../orders/viewmodels/orders_viewmodel.dart';
import '../../orders/models/daily_order_model.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/services/haptic_service.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  @override
  void initState() {
    super.initState();
    context.read<HomeViewModel>().add(const LoadHomeDashboard());
    context.read<OrdersViewModel>().add(const LoadOrders());
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
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
                              'No',
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
                          context.read<OrdersViewModel>().add(UpdateOrderStatus(order.orderId, newStatus));
                          Navigator.pop(dialogContext);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                          decoration: BoxDecoration(
                            color: actionColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'Yes, Confirm',
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
      body: BlocBuilder<HomeViewModel, HomeState>(
        builder: (context, homeState) {
          if (homeState.isLoading) {
            return const SafeArea(child: SkeletonDashboard());
          }
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting Header with Profile Icon
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: hPadding, vertical: scaleF(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()},',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(14),
                              fontWeight: FontWeight.w500,
                              color: PaalvandiTheme.textSecondary,
                            ),
                          ),
                          Text(
                            homeState.partnerName,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(24),
                              fontWeight: FontWeight.w900,
                              color: PaalvandiTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticService.light();
                          context.push('/profile');
                        },
                        child: Container(
                          padding: EdgeInsets.all(scaleF(10)),
                          decoration: BoxDecoration(
                            color: PaalvandiTheme.cardWhite,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: PaalvandiTheme.textDark,
                            size: scaleF(24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orders Overview',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(18),
                          fontWeight: FontWeight.w900,
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                      Text(
                        'Quick summary of today\'s tasks',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(11),
                          color: PaalvandiTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleF(16)),

                // Orders Dashboard
                Expanded(
                  child: BlocBuilder<OrdersViewModel, OrdersState>(
                    builder: (context, ordersState) {
                      if (ordersState.isLoading) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPadding),
                          child: const SkeletonCard(),
                        );
                      }

                      final assignedOrders = ordersState.orders.where((o) => o.status == 'Assigned').length;
                      final acceptedOrders = ordersState.orders.where((o) => o.status == 'Accepted').length;
                      final deliveredOrders = ordersState.orders.where((o) => o.status == 'Delivered').length;
                      final cancelledOrders = ordersState.orders.where((o) => o.status == 'Cancelled' || o.status == 'Rejected').length;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(8)),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 1.3,
                          crossAxisSpacing: scaleF(12),
                          mainAxisSpacing: scaleF(12),
                          children: [
                            _buildDashboardCard(
                              'ASSIGNED BY ADMIN',
                              '$assignedOrders',
                              Icons.assignment_ind_outlined,
                              PaalvandiTheme.preparingAmber,
                              scaleF,
                              fs,
                            ),
                            _buildDashboardCard(
                              'ACCEPTED BY YOU',
                              '$acceptedOrders',
                              Icons.thumb_up_alt_outlined,
                              PaalvandiTheme.assignedBlue,
                              scaleF,
                              fs,
                            ),
                            _buildDashboardCard(
                              'DELIVERED TODAY',
                              '$deliveredOrders',
                              Icons.local_shipping_outlined,
                              PaalvandiTheme.deliveredGreen,
                              scaleF,
                              fs,
                            ),
                            _buildDashboardCard(
                              'CANCELLED TODAY',
                              '$cancelledOrders',
                              Icons.cancel_outlined,
                              PaalvandiTheme.statusError,
                              scaleF,
                              fs,
                            ),
                            _buildDashboardCard(
                              'BULK ORDERS',
                              '${homeState.bulkOrders}',
                              Icons.inventory_2_outlined,
                              PaalvandiTheme.primaryBlue,
                              scaleF,
                              fs,
                            ),
                            _buildDashboardCard(
                              'SUBSCRIPTIONS',
                              '${homeState.subscriptionDeliveries}',
                              Icons.autorenew_outlined,
                              PaalvandiTheme.accentGreen,
                              scaleF,
                              fs,
                            ),
                            _buildDashboardCard(
                              'BOTTLE COLLECTIONS',
                              '${homeState.bottleCollections}',
                              Icons.recycling_outlined,
                              PaalvandiTheme.statusPending,
                              scaleF,
                              fs,
                            ),
                            _buildDashboardCard(
                              'MILK DELIVERED',
                              '${homeState.milkQuantityDelivered.toStringAsFixed(1)} L',
                              Icons.water_drop_outlined,
                              PaalvandiTheme.statusSuccess,
                              scaleF,
                              fs,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Function scaleF,
    Function fs,
  ) {
    return Container(
      padding: EdgeInsets.all(scaleF(12)),
      decoration: PaalvandiTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(8),
                    fontWeight: FontWeight.bold,
                    color: PaalvandiTheme.textSecondary,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: scaleF(16)),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: fs(24),
              fontWeight: FontWeight.w900,
              color: PaalvandiTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, DailyOrderModel order, Function scaleF, Function fs) {
    Color cardBgColor;
    if (order.status == 'Accepted') {
      cardBgColor = const Color(0xFFE8F5E9); // Light Green
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
                    order.status == 'Assigned' ? 'Assigned' : 'Accepted',
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

            // Customer Name
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
                      fontWeight: FontWeight.bold,
                      color: PaalvandiTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleF(6)),

            // Address
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

            // Product List Brief
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.products.map((p) {
                return Padding(
                  padding: EdgeInsets.only(bottom: scaleF(4)),
                  child: Row(
                    children: [
                      Container(
                        width: scaleF(6),
                        height: scaleF(6),
                        decoration: const BoxDecoration(
                          color: PaalvandiTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: scaleF(8)),
                      Expanded(
                        child: Text(
                          '${p.name} (${p.unit}) × ${p.quantity}',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            color: PaalvandiTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: scaleF(12)),

            // Row containing badges (Delivery Type, Payment Method)
            Row(
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
                              PaalvandiTheme.statusWarning),
                          child: Text(
                            'Deposit: ₹${order.bottleDepositAmount.toStringAsFixed(0)}',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(9),
                              fontWeight: FontWeight.bold,
                              color: PaalvandiTheme.statusWarning,
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

            // Solid Flat Action Buttons
            if (order.status == 'Assigned') ...[
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      'Cancel Order',
                      Icons.cancel_outlined,
                      PaalvandiTheme.statusError,
                      () => _showStatusConfirmDialog(
                          context, order, 'Cancelled', 'Cancel', PaalvandiTheme.statusError, scaleF, fs),
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
                        final hasActiveAccepted = context
                            .read<OrdersViewModel>()
                            .state
                            .orders
                            .any((o) => o.status == 'Accepted');
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        } else {
                          _showStatusConfirmDialog(
                              context, order, 'Accepted', 'Accept', PaalvandiTheme.accentGreen, scaleF, fs);
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
                            Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=$encoded'),
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
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.5),
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
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
