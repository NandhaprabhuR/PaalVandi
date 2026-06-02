import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/delivery_theme.dart';
import '../../home/viewmodels/delivery_home_viewmodel.dart';
import '../../core/widgets/responsive_helper.dart';

class DeliveryEarningsView extends StatelessWidget {
  const DeliveryEarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleF = (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs = (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return BlocBuilder<DeliveryHomeViewModel, DeliveryHomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: DeliveryTheme.bgDark,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Earnings Hub',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(22),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: scaleF(24)),

                  // Weekly overview stats card
                  _buildWeeklySummaryCard(state, fs, scaleF),
                  SizedBox(height: scaleF(24)),

                  // Instant payout request button (Tactile GPAY blue styled)
                  _buildPayoutWidget(context, state, fs, scaleF),
                  SizedBox(height: scaleF(28)),

                  // Trip History Header
                  Text(
                    'Trip Earnings History',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(16),
                      fontWeight: FontWeight.bold,
                      color: DeliveryTheme.textLight,
                    ),
                  ),
                  SizedBox(height: scaleF(12)),

                  // Historical trips list
                  _buildHistoricalTripsList(fs, scaleF),
                  SizedBox(height: scaleF(40)),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context, 1, scaleF, fs),
        );
      },
    );
  }

  Widget _buildWeeklySummaryCard(DeliveryHomeState state, Function fs, Function scaleF) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'THIS WEEK\'S EARNINGS',
                style: GoogleFonts.montserrat(
                  fontSize: fs(10),
                  fontWeight: FontWeight.bold,
                  color: DeliveryTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(2)),
                decoration: BoxDecoration(
                  color: DeliveryTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Mon, Jun 1 - Today',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(9),
                    fontWeight: FontWeight.bold,
                    color: DeliveryTheme.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(12)),
          Text(
            '₹${(state.todayEarnings + 2450.00).toStringAsFixed(2)}',
            style: GoogleFonts.montserrat(
              fontSize: fs(28),
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(height: scaleF(16)),
          // Chart placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar('Mon', scaleF(30), fs, scaleF),
              _buildBar('Tue', scaleF(45), fs, scaleF),
              _buildBar('Wed', scaleF(20), fs, scaleF),
              _buildBar('Thu', scaleF(60), fs, scaleF),
              _buildBar('Fri', scaleF(40), fs, scaleF),
              _buildBar('Sat', scaleF(75), fs, scaleF),
              _buildBar('Sun (Today)', scaleF(90), fs, scaleF, isHighlight: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double height, Function fs, Function scaleF, {bool isHighlight = false}) {
    return Column(
      children: [
        Container(
          width: scaleF(16),
          height: scaleF(height),
          decoration: BoxDecoration(
            color: isHighlight ? DeliveryTheme.primaryOrange : DeliveryTheme.borderDark,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: scaleF(8)),
        Text(
          day.substring(0, 3),
          style: GoogleFonts.montserrat(
            fontSize: fs(9),
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? DeliveryTheme.textLight : DeliveryTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutWidget(BuildContext context, DeliveryHomeState state, Function fs, Function scaleF) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Withdrawable Balance',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    color: DeliveryTheme.textSecondary,
                  ),
                ),
                Text(
                  '₹${(state.todayEarnings + 820.00).toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(18),
                    fontWeight: FontWeight.w900,
                    color: DeliveryTheme.statusOnline,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Payout request of ₹${(state.todayEarnings + 820.00).toStringAsFixed(2)} processed to GPay successfully!',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  backgroundColor: DeliveryTheme.gpayBlue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DeliveryTheme.gpayBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(12)),
            ),
            child: Text(
              'Payout to GPay',
              style: GoogleFonts.montserrat(
                fontSize: fs(12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalTripsList(Function fs, Function scaleF) {
    // Beautiful mock delivery trip history records showing standard 5-character alphanumeric ID structures
    final List<Map<String, dynamic>> historicalTrips = [
      {
        'id': 'K9X2B',
        'type': 'Order',
        'earning': 45.00,
        'distance': '3.2 km',
        'time': 'Today, 07:15 AM',
        'customer': 'Nandha Prabhu',
      },
      {
        'id': 'P8R2W',
        'type': 'Bulk Booking',
        'earning': 120.00,
        'distance': '7.5 km',
        'time': 'Today, 06:40 AM',
        'customer': 'Hotel Temple Towers',
      },
      {
        'id': 'S2Y8W',
        'type': 'Subscription',
        'earning': 30.00,
        'distance': '1.8 km',
        'time': 'Yesterday, 07:45 AM',
        'customer': 'Rajesh Kumar',
      },
      {
        'id': 'M3T8P',
        'type': 'Order',
        'earning': 45.00,
        'distance': '4.1 km',
        'time': 'Yesterday, 06:12 AM',
        'customer': 'Sridhar Subramanian',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: historicalTrips.length,
      separatorBuilder: (c, idx) => SizedBox(height: scaleF(12)),
      itemBuilder: (context, index) {
        final trip = historicalTrips[index];
        return Container(
          decoration: BoxDecoration(
            color: DeliveryTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
          ),
          padding: EdgeInsets.all(scaleF(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: scaleF(20),
                    backgroundColor: DeliveryTheme.borderDark,
                    child: Icon(
                      trip['type'] == 'Bulk Booking' ? Icons.local_shipping_outlined : Icons.sports_motorsports_outlined,
                      color: DeliveryTheme.primaryOrange,
                      size: scaleF(20),
                    ),
                  ),
                  SizedBox(width: scaleF(16)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip['type']} ID: ${trip['id']}',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'To: ${trip['customer']} (${trip['distance']})',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(11),
                          color: DeliveryTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: scaleF(2)),
                      Text(
                        trip['time'],
                        style: GoogleFonts.montserrat(
                          fontSize: fs(10),
                          color: DeliveryTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '+ ₹${trip['earning'].toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(
                  fontSize: fs(14),
                  fontWeight: FontWeight.w900,
                  color: DeliveryTheme.statusOnline,
                ),
              ),
            ],
          ),
        );
      },
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
