import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../models/delivery_order_model.dart';
import '../viewmodels/delivery_home_viewmodel.dart';
import '../../theme/delivery_theme.dart';
import '../../core/widgets/responsive_helper.dart';

class DeliveryHomeView extends StatelessWidget {
  const DeliveryHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleF = (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs = (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: DeliveryTheme.bgDark,
      body: BlocBuilder<DeliveryHomeViewModel, DeliveryHomeState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Row
                  _buildHeader(context, state, fs, scaleF),
                  SizedBox(height: scaleF(20)),

                  // Online Duty Switch (GPAY styled tactile controller)
                  _buildOnlineDutyToggle(context, state, fs, scaleF),
                  SizedBox(height: scaleF(24)),

                  if (!state.isOnline) ...[
                    // Offline Info
                    _buildOfflineDashboard(fs, scaleF),
                  ] else ...[
                    // Metrics Grid (GPay inspired card dashboard)
                    _buildMetricsGrid(state, fs, scaleF),
                    SizedBox(height: scaleF(28)),

                    // Active Order Card (If any accepted)
                    if (state.activeOrder != null) ...[
                      _buildActiveOrderSection(context, state.activeOrder!, fs, scaleF),
                      SizedBox(height: scaleF(28)),
                    ],

                    // Assigned Deliveries Header
                    Text(
                      'Pending Pickups (${state.assignedOrders.length})',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(16),
                        fontWeight: FontWeight.bold,
                        color: DeliveryTheme.textLight,
                      ),
                    ),
                    SizedBox(height: scaleF(12)),

                    // Assigned Deliveries List
                    if (state.assignedOrders.isEmpty && state.activeOrder == null)
                      _buildNoOrdersWidget(fs, scaleF)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.assignedOrders.length,
                        separatorBuilder: (c, idx) => SizedBox(height: scaleF(16)),
                        itemBuilder: (context, index) {
                          final order = state.assignedOrders[index];
                          return _buildOrderCard(context, order, fs, scaleF);
                        },
                      ),
                  ],
                  SizedBox(height: scaleF(40)),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context, 0, scaleF, fs),
    );
  }

  Widget _buildHeader(BuildContext context, DeliveryHomeState state, Function fs, Function scaleF) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, partner!',
              style: GoogleFonts.montserrat(
                fontSize: fs(12),
                fontWeight: FontWeight.w600,
                color: DeliveryTheme.textSecondary,
              ),
            ),
            SizedBox(height: scaleF(4)),
            Text(
              'Ravi Kumar',
              style: GoogleFonts.montserrat(
                fontSize: fs(20),
                fontWeight: FontWeight.w900,
                color: DeliveryTheme.textLight,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: DeliveryTheme.borderDark,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: scaleF(24),
              backgroundColor: DeliveryTheme.cardDark,
              child: Icon(Icons.delivery_dining, color: DeliveryTheme.primaryOrange, size: scaleF(28)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineDutyToggle(BuildContext context, DeliveryHomeState state, Function fs, Function scaleF) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: scaleF(10),
                height: scaleF(10),
                decoration: BoxDecoration(
                  color: state.isOnline ? DeliveryTheme.statusOnline : DeliveryTheme.statusOffline,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (state.isOnline ? DeliveryTheme.statusOnline : DeliveryTheme.statusOffline).withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(width: scaleF(12)),
              Text(
                state.isOnline ? 'ONLINE - Active Duty' : 'OFFLINE - On Break',
                style: GoogleFonts.montserrat(
                  fontSize: fs(14),
                  fontWeight: FontWeight.w800,
                  color: DeliveryTheme.textLight,
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: state.isOnline,
            activeColor: DeliveryTheme.statusOnline,
            activeTrackColor: DeliveryTheme.statusOnline.withOpacity(0.2),
            inactiveThumbColor: DeliveryTheme.textSecondary,
            inactiveTrackColor: DeliveryTheme.borderDark,
            onChanged: (val) {
              context.read<DeliveryHomeViewModel>().add(const ToggleOnlineStatus());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineDashboard(Function fs, Function scaleF) {
    return Card(
      color: DeliveryTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: scaleF(24), vertical: scaleF(40)),
        child: Column(
          children: [
            Lottie.asset(
              'assets/animations/fresh milk.json',
              height: scaleF(140),
            ),
            SizedBox(height: scaleF(24)),
            Text(
              'Start Your Shift',
              style: GoogleFonts.montserrat(
                fontSize: fs(18),
                fontWeight: FontWeight.bold,
                color: DeliveryTheme.textLight,
              ),
            ),
            SizedBox(height: scaleF(8)),
            Text(
              'Toggle the switch to go online. You will receive active notifications for dairy delivery pickups near Gandhipuram.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: fs(12),
                color: DeliveryTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(DeliveryHomeState state, Function fs, Function scaleF) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: scaleF(12),
      mainAxisSpacing: scaleF(12),
      childAspectRatio: 0.9,
      children: [
        _buildMetricCard('Today Earnings', '₹${state.todayEarnings.toStringAsFixed(2)}', Icons.payments_outlined, fs, scaleF),
        _buildMetricCard('Trips Completed', '${state.todayDeliveriesCount}', Icons.sports_motorsports_outlined, fs, scaleF),
        _buildMetricCard('Distance Done', '${state.todayDistanceKm} km', Icons.route_outlined, fs, scaleF),
      ],
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Function fs, Function scaleF) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: DeliveryTheme.primaryOrange, size: scaleF(24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                val,
                style: GoogleFonts.montserrat(
                  fontSize: fs(16),
                  fontWeight: FontWeight.w900,
                  color: DeliveryTheme.textLight,
                ),
              ),
              SizedBox(height: scaleF(2)),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: fs(10),
                  fontWeight: FontWeight.w600,
                  color: DeliveryTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderSection(BuildContext context, DeliveryOrderModel active, Function fs, Function scaleF) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Delivery',
          style: GoogleFonts.montserrat(
            fontSize: fs(16),
            fontWeight: FontWeight.bold,
            color: DeliveryTheme.textLight,
          ),
        ),
        SizedBox(height: scaleF(12)),
        GestureDetector(
          onTap: () => context.go('/order-detail'),
          child: Container(
            decoration: BoxDecoration(
              color: DeliveryTheme.primaryOrange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DeliveryTheme.primaryOrange.withOpacity(0.3), width: 1.5),
            ),
            padding: EdgeInsets.all(scaleF(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: scaleF(10), vertical: scaleF(4)),
                      decoration: BoxDecoration(
                        color: DeliveryTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        active.orderType.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: fs(10),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      'ID: ${active.orderId}',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(13),
                        fontWeight: FontWeight.bold,
                        color: DeliveryTheme.textLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: scaleF(16)),
                Row(
                  children: [
                    Icon(Icons.location_on, color: DeliveryTheme.primaryOrange, size: scaleF(20)),
                    SizedBox(width: scaleF(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            active.customerName,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(14),
                              fontWeight: FontWeight.bold,
                              color: DeliveryTheme.textLight,
                            ),
                          ),
                          SizedBox(height: scaleF(2)),
                          Text(
                            active.address,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              color: DeliveryTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: DeliveryTheme.textSecondary, size: scaleF(24)),
                  ],
                ),
                SizedBox(height: scaleF(16)),
                // Quick progress row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Stage: ${active.deliveryStatus}',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12),
                        fontWeight: FontWeight.bold,
                        color: DeliveryTheme.primaryOrange,
                      ),
                    ),
                    Text(
                      'Slot: ${active.timeSlot}',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        fontWeight: FontWeight.w600,
                        color: DeliveryTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoOrdersWidget(Function fs, Function scaleF) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(24)),
      child: Column(
        children: [
          Lottie.asset(
            'assets/animations/noitemincart.json',
            height: scaleF(100),
          ),
          SizedBox(height: scaleF(16)),
          Text(
            'Waiting for Orders...',
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              color: DeliveryTheme.textLight,
            ),
          ),
          SizedBox(height: scaleF(4)),
          Text(
            'Enjoy a sip of water. We will notify you when a customer makes an order.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: fs(11),
              color: DeliveryTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, DeliveryOrderModel order, Function fs, Function scaleF) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(3)),
                    decoration: BoxDecoration(
                      color: DeliveryTheme.borderDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.orderType,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(10),
                        fontWeight: FontWeight.bold,
                        color: DeliveryTheme.primaryOrange,
                      ),
                    ),
                  ),
                  SizedBox(width: scaleF(8)),
                  Text(
                    'ID: ${order.orderId}',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(13),
                      fontWeight: FontWeight.bold,
                      color: DeliveryTheme.textLight,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${order.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(
                  fontSize: fs(15),
                  fontWeight: FontWeight.w900,
                  color: DeliveryTheme.textLight,
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.radio_button_checked, color: DeliveryTheme.primaryOrange, size: scaleF(16)),
              SizedBox(width: scaleF(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PaalVandi Coimbatore Hub',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12),
                        fontWeight: FontWeight.bold,
                        color: DeliveryTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '1.2 km away from your location',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(10),
                        color: DeliveryTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(8)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: DeliveryTheme.statusOnline, size: scaleF(16)),
              SizedBox(width: scaleF(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.address,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(13),
                        fontWeight: FontWeight.bold,
                        color: DeliveryTheme.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Customer: ${order.customerName} (${order.timeSlot})',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        color: DeliveryTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(20)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.isCod ? 'Collect on Delivery' : 'Already Paid Online',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        fontWeight: FontWeight.bold,
                        color: order.isCod ? DeliveryTheme.accentAmber : DeliveryTheme.statusOnline,
                      ),
                    ),
                    if (order.isCod)
                      Text(
                        'Collect: ₹${(order.totalAmount - order.advancePaid).toStringAsFixed(2)}',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          fontWeight: FontWeight.w900,
                          color: DeliveryTheme.textLight,
                        ),
                      ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<DeliveryHomeViewModel>().add(AcceptOrder(order.orderId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Trip ${order.orderId} accepted successfully!',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      backgroundColor: DeliveryTheme.statusOnline,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DeliveryTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: scaleF(20), vertical: scaleF(10)),
                ),
                child: Text(
                  'Accept Trip',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int activeIdx, Function scaleF, Function fs) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        border: Border(top: BorderSide(color: DeliveryTheme.borderDark, width: 1.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: activeIdx,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: DeliveryTheme.primaryOrange,
        unselectedItemColor: DeliveryTheme.textSecondary,
        selectedLabelStyle: GoogleFonts.montserrat(fontSize: fs(11), fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.montserrat(fontSize: fs(11), fontWeight: FontWeight.w500),
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/earnings');
          if (index == 2) context.go('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.currency_rupee_outlined), activeIcon: Icon(Icons.currency_rupee), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
