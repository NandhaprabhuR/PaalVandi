import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../models/booked_subscription_model.dart';

class MonthlyTimelineMapView extends StatelessWidget {
  final BookedSubscription booking;
  
  // Same mock statuses for May 2026
  final Map<int, String> _dayStatuses = {
    4: 'delivered',
    5: 'delivered',
    6: 'delivered',
    7: 'delivered',
    8: 'adjusted',
    9: 'delivered',
    10: 'delivered',
    11: 'delivered',
    12: 'delivered',
    13: 'delivered',
    14: 'cancelled',
    15: 'delivered',
    16: 'delivered',
    17: 'adjusted',
    18: 'delivered',
    19: 'delivered',
    20: 'delivered',
    21: 'delivered',
    22: 'delivered',
    23: 'cancelled',
    24: 'delivered',
    25: 'delivered',
    26: 'delivered',
  };

  MonthlyTimelineMapView({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    final isBoth = booking.configSummary.any((line) => line.contains('Both') || line.contains('Morning + Evening'));
    final isMorningOnly = booking.configSummary.any((line) => line.contains('Morning')) && !isBoth;
    final isEveningOnly = booking.configSummary.any((line) => line.contains('Evening')) && !isBoth;
    final quantity = booking.configSummary.firstWhere((line) => line.contains('Quantity:'), orElse: () => 'Quantity: 500ml').replaceAll('Quantity:', '').trim();

    final todayDay = 24; // May 24, 2026

    final String planTitle = booking.planTitle;
    Color themeColor = const Color(0xFFE2F4E2); // default soft green tint
    Color scaffoldBg = const Color(0xFFF9FBF9); // default soft white-green
    if (planTitle.contains('Family')) {
      themeColor = const Color(0xFFE8F2FA); // Soft Blue
      scaffoldBg = const Color(0xFFF0F5FA);
    } else if (planTitle.contains('Business')) {
      themeColor = const Color(0xFFFFF0E0); // Soft Orange
      scaffoldBg = const Color(0xFFFFFAF5);
    } else if (planTitle.contains('Event')) {
      themeColor = const Color(0xFFF0E8F8); // Soft Purple
      scaffoldBg = const Color(0xFFF7F3FC);
    } else if (planTitle.contains('Smart')) {
      themeColor = const Color(0xFFE6F2EA); // Soft Green
      scaffoldBg = const Color(0xFFF2F8F4);
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: CustomersLoginThemeView.primaryBlue,
            size: scaleF(24).clamp(20.0, 28.0),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Monthly Delivery Map',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(19),
            color: CustomersLoginThemeView.primaryBlue,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: scaffoldBg,
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
          children: [
            // Top Dashboard Banner Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(scaleF(16)),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(scaleF(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Delivered', '23 Days', const Color(0xFF4CAF50), scaleF, fs),
                      Container(width: 1, height: scaleF(30), color: CustomersLoginThemeView.borderColor),
                      _buildStatColumn('Adjusted', '2 Days', const Color(0xFFFF9800), scaleF, fs),
                      Container(width: 1, height: scaleF(30), color: CustomersLoginThemeView.borderColor),
                      _buildStatColumn('Cancelled', '2 Days', const Color(0xFFEF5350), scaleF, fs),
                    ],
                  ),
                ),
              ),
            ),
            
            // Timeline Scrollable Map List
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
                itemCount: 31,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final date = DateTime(2026, 5, day);
                  final status = _dayStatuses[day];
                  final isFuture = day > todayDay;
                  final isToday = day == todayDay;
                  
                  return _buildMapTimelineItem(
                    day: day,
                    date: date,
                    status: status,
                    isFuture: isFuture,
                    isToday: isToday,
                    isMorning: isMorningOnly,
                    isEvening: isEveningOnly,
                    isBoth: isBoth,
                    quantity: quantity,
                    isLast: day == 31,
                    scaleF: scaleF,
                    fs: fs,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color, double Function(double) scaleF, double Function(double) fs) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: fs(15),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: scaleF(2)),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: fs(10),
            fontWeight: FontWeight.w600,
            color: CustomersLoginThemeView.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildMapTimelineItem({
    required int day,
    required DateTime date,
    required String? status,
    required bool isFuture,
    required bool isToday,
    required bool isMorning,
    required bool isEvening,
    required bool isBoth,
    required String quantity,
    required bool isLast,
    required double Function(double) scaleF,
    required double Function(double) fs,
  }) {
    // Determine colors & icons based on status
    Color nodeColor = Colors.grey.shade300;
    IconData nodeIcon = Icons.calendar_today;
    String statusLabel = 'Upcoming';
    Color tagColor = CustomersLoginThemeView.primaryBlue;
    
    if (isFuture) {
      statusLabel = 'Scheduled';
      nodeColor = Colors.grey.shade300;
      nodeIcon = Icons.arrow_forward_ios;
      tagColor = Colors.grey.shade500;
    } else if (status == 'delivered') {
      statusLabel = 'Delivered';
      nodeColor = const Color(0xFF4CAF50);
      nodeIcon = Icons.check;
      tagColor = const Color(0xFF4CAF50);
    } else if (status == 'adjusted') {
      statusLabel = 'Rescheduled';
      nodeColor = const Color(0xFFFF9800);
      nodeIcon = Icons.access_time;
      tagColor = const Color(0xFFFF9800);
    } else if (status == 'cancelled') {
      statusLabel = 'Cancelled';
      nodeColor = const Color(0xFFEF5350);
      nodeIcon = Icons.close;
      tagColor = const Color(0xFFEF5350);
    } else {
      // Past day but no explicit status (e.g. prior to subscription start)
      statusLabel = 'No Delivery';
      nodeColor = Colors.grey.shade400;
      nodeIcon = Icons.remove;
      tagColor = Colors.grey;
    }

    final dayName = DateFormat('EEEE').format(date);
    final dateStr = DateFormat('dd MMM yyyy').format(date);
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Node Icon & Path Line
          Column(
            children: [
              // Icon Node representing "Map Station"
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: scaleF(34),
                    height: scaleF(34),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: nodeColor,
                      boxShadow: [
                        BoxShadow(
                          color: nodeColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      nodeIcon,
                      color: Colors.white,
                      size: scaleF(16),
                    ),
                  ),
                  if (isToday)
                    Positioned(
                      top: -scaleF(4),
                      child: Text(
                        '🚚',
                        style: TextStyle(fontSize: scaleF(12)),
                      ),
                    ),
                ],
              ),
              // Connecting Road/Path
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: isFuture
                          ? Colors.grey.shade200
                          : nodeColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: scaleF(14)),
          
          // Right Map Card Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: scaleF(16)),
              child: Container(
                padding: EdgeInsets.all(scaleF(12)),
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFFF1FDF3) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isToday
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                        : CustomersLoginThemeView.borderColor.withValues(alpha: 0.4),
                    width: isToday ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isToday ? 0.06 : 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$dayName, $dateStr',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? const Color(0xFF2E7D32)
                                : CustomersLoginThemeView.textDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(9),
                              fontWeight: FontWeight.bold,
                              color: tagColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: scaleF(6)),
                    Text(
                      status == 'cancelled'
                          ? 'Subscription paused/cancelled for today'
                          : (status == 'adjusted'
                              ? 'Rescheduled delivery'
                              : (isFuture ? 'Scheduled delivery' : 'Delivered successfully')),
                      style: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        fontWeight: FontWeight.w600,
                        color: status == 'cancelled'
                            ? Colors.red.shade400
                            : (isFuture ? Colors.grey.shade600 : CustomersLoginThemeView.textDark),
                      ),
                    ),
                    if (status != 'cancelled' && statusLabel != 'No Delivery') ...[
                      SizedBox(height: scaleF(4)),
                      Row(
                        children: [
                          Icon(
                            Icons.opacity,
                            color: const Color(0xFF2196F3),
                            size: scaleF(12),
                          ),
                          SizedBox(width: scaleF(4)),
                          Text(
                            '$quantity Cow Milk',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(10),
                              fontWeight: FontWeight.w500,
                              color: CustomersLoginThemeView.textGrey,
                            ),
                          ),
                          SizedBox(width: scaleF(12)),
                          Icon(
                            Icons.access_time_filled_rounded,
                            color: const Color(0xFFEC407A),
                            size: scaleF(12),
                          ),
                          SizedBox(width: scaleF(4)),
                          Text(
                            isBoth
                                ? 'Morning & Evening'
                                : (isMorning ? 'Morning only' : 'Evening only'),
                            style: GoogleFonts.montserrat(
                              fontSize: fs(10),
                              fontWeight: FontWeight.w500,
                              color: CustomersLoginThemeView.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
