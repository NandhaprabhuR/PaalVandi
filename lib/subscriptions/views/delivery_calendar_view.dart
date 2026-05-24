import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../models/booked_subscription_model.dart';
import 'monthly_timeline_map_view.dart';

class DeliveryCalendarView extends StatefulWidget {
  final BookedSubscription booking;

  const DeliveryCalendarView({super.key, required this.booking});

  @override
  State<DeliveryCalendarView> createState() => _DeliveryCalendarViewState();
}

class _DeliveryCalendarViewState extends State<DeliveryCalendarView> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  // Mock statuses for the calendar days of May 2026
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

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(2026, 5, 1);
    _selectedDay = DateTime(2026, 5, 24);
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    final isBoth = widget.booking.configSummary.any((line) => line.contains('Both') || line.contains('Morning + Evening'));
    final isMorningOnly = widget.booking.configSummary.any((line) => line.contains('Morning')) && !isBoth;
    final isEveningOnly = widget.booking.configSummary.any((line) => line.contains('Evening')) && !isBoth;

    final String planTitle = widget.booking.planTitle;
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
          'My Subscription Tracker',
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Section Container with premium styling
              Container(
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(hPadding, scaleF(8), hPadding, scaleF(24)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: DateFormat('MMMM yyyy').format(_focusedMonth),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                            style: GoogleFonts.montserrat(
                              fontSize: fs(16),
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            alignment: Alignment.centerLeft,
                            items: [
                              DropdownMenuItem(
                                value: 'April 2026',
                                child: Text('April 2026', style: GoogleFonts.montserrat(fontSize: fs(14), color: CustomersLoginThemeView.textDark)),
                              ),
                              DropdownMenuItem(
                                value: 'May 2026',
                                child: Text('May 2026', style: GoogleFonts.montserrat(fontSize: fs(14), fontWeight: FontWeight.bold, color: CustomersLoginThemeView.primaryBlue)),
                              ),
                              DropdownMenuItem(
                                value: 'June 2026',
                                child: Text('June 2026', style: GoogleFonts.montserrat(fontSize: fs(14), color: CustomersLoginThemeView.textDark)),
                              ),
                              DropdownMenuItem(
                                value: 'July 2026',
                                child: Text('July 2026', style: GoogleFonts.montserrat(fontSize: fs(14), color: CustomersLoginThemeView.textDark)),
                              ),
                              DropdownMenuItem(
                                value: 'today',
                                child: Row(
                                  children: [
                                    const Icon(Icons.today_rounded, size: 18, color: Color(0xFF4CAF50)),
                                    SizedBox(width: scaleF(6)),
                                    Text(
                                      'Go to Today Date',
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(12),
                                        fontWeight: FontWeight.bold,
                                        color: CustomersLoginThemeView.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val == 'today') {
                                setState(() {
                                  _selectedDay = DateTime(2026, 5, 24);
                                  _focusedMonth = DateTime(2026, 5, 1);
                                });
                              } else if (val != null) {
                                setState(() {
                                  if (val == 'April 2026') {
                                    _focusedMonth = DateTime(2026, 4, 1);
                                  } else if (val == 'May 2026') {
                                    _focusedMonth = DateTime(2026, 5, 1);
                                  } else if (val == 'June 2026') {
                                    _focusedMonth = DateTime(2026, 6, 1);
                                  } else if (val == 'July 2026') {
                                    _focusedMonth = DateTime(2026, 7, 1);
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        Text(
                          '${_dayStatuses.values.where((s) => s == 'delivered').length} Delivered Total',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: FontWeight.bold,
                            color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: scaleF(16)),

                    // Days of week header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) {
                        return SizedBox(
                          width: scaleF(40),
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(11),
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: scaleF(10)),

                    // 5-week grid starts dynamically based on selected month
                    _buildCalendarGrid(_focusedMonth, isMorningOnly, isEveningOnly, isBoth, scaleF, fs),
                  ],
                ),
              ),

              // Calendar Legend
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
                child: Container(
                  padding: EdgeInsets.all(scaleF(12)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _legendItem('Delivered', const Color(0xFF4CAF50), scaleF, fs, half: isMorningOnly || isEveningOnly),
                      _legendItem('Adjusted', const Color(0xFFFF9800), scaleF, fs),
                      _legendItem('Cancelled', const Color(0xFFEF5350), scaleF, fs),
                    ],
                  ),
                ),
              ),

              // Daily Timeline Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Timeline - ${DateFormat('dd MMMM yyyy').format(_selectedDay)}',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    if (_focusedMonth.month == 5 && _dayStatuses[_selectedDay.day] != null)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MonthlyTimelineMapView(booking: widget.booking),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map_outlined, size: 16, color: Color(0xFF4CAF50)),
                        label: Text(
                          'View Monthly Map',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: scaleF(16)),

              // Timeline List widget matching the reference UI
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: _buildTimelineSection(isMorningOnly, isEveningOnly, isBoth, scaleF, fs),
              ),
              SizedBox(height: scaleF(32)),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _legendItem(String label, Color color, double Function(double) scaleF, double Function(double) fs, {bool half = false}) {
    return Row(
      children: [
        Container(
          width: scaleF(16),
          height: scaleF(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: half ? Colors.transparent : color,
            border: Border.all(color: color, width: 1),
            gradient: half
                ? LinearGradient(
                    colors: [color, const Color(0xFFE8F5E9)],
                    stops: const [0.5, 0.5],
                  )
                : null,
          ),
        ),
        SizedBox(width: scaleF(6)),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: fs(11),
            fontWeight: FontWeight.w600,
            color: CustomersLoginThemeView.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(DateTime month, bool isMorning, bool isEvening, bool isBoth, double Function(double) scaleF, double Function(double) fs) {
    final gridItems = <Widget>[];
    
    final startingEmptyDays = month.weekday % 7;
    for (int i = 0; i < startingEmptyDays; i++) {
      gridItems.add(SizedBox(width: scaleF(40), height: scaleF(40)));
    }

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final isSelected = _selectedDay.year == month.year && _selectedDay.month == month.month && _selectedDay.day == day;
      final status = month.month == 5 ? _dayStatuses[day] : null;
      
      BoxDecoration? decoration;
      Gradient? gradient;
      Color textColor = CustomersLoginThemeView.textDark;

      if (status == 'delivered') {
        if (isBoth) {
          decoration = const BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          );
          textColor = Colors.white;
        } else if (isMorning) {
          gradient = const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFFE8F5E9)],
            stops: [0.5, 0.5],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          );
          decoration = const BoxDecoration(
            shape: BoxShape.circle,
          );
          textColor = const Color(0xFF1B5E20); // Dark Green - highly visible even when selected!
        } else if (isEvening) {
          gradient = const LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFF4CAF50)],
            stops: [0.5, 0.5],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          );
          decoration = const BoxDecoration(
            shape: BoxShape.circle,
          );
          textColor = const Color(0xFF1B5E20); // Dark Green - highly visible even when selected!
        } else {
          decoration = const BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          );
          textColor = Colors.white;
        }
      } else if (status == 'adjusted') {
        decoration = const BoxDecoration(
          color: Color(0xFFFF9800),
          shape: BoxShape.circle,
        );
        textColor = Colors.white;
      } else if (status == 'cancelled') {
        decoration = const BoxDecoration(
          color: Color(0xFFEF5350),
          shape: BoxShape.circle,
        );
        textColor = Colors.white;
      } else {
        if (isSelected) {
          decoration = const BoxDecoration(
            color: CustomersLoginThemeView.primaryBlue,
            shape: BoxShape.circle,
          );
          textColor = Colors.white;
        }
      }

      if (isSelected && status != null) {
        decoration = decoration?.copyWith(
          border: Border.all(
            color: CustomersLoginThemeView.primaryBlue,
            width: 2.5,
          ),
        ) ?? BoxDecoration(
          border: Border.all(
            color: CustomersLoginThemeView.primaryBlue,
            width: 2.5,
          ),
          shape: BoxShape.circle,
        );
      }

      Widget dayChild = Center(
        child: Text(
          '$day',
          style: GoogleFonts.montserrat(
            fontSize: fs(13),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: textColor,
            decoration: status == 'cancelled' ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white,
          ),
        ),
      );

      gridItems.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, day);
            });
          },
          child: Container(
            width: scaleF(40),
            height: scaleF(40),
            margin: const EdgeInsets.all(2),
            decoration: decoration?.copyWith(gradient: gradient),
            child: dayChild,
          ),
        ),
      );
    }

    // Wrap in rows of 7
    final rows = <Widget>[];
    for (int i = 0; i < gridItems.length; i += 7) {
      final rowChildren = gridItems.sublist(i, (i + 7).clamp(0, gridItems.length));
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: rowChildren,
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildTimelineSection(bool isMorning, bool isEvening, bool isBoth, double Function(double) scaleF, double Function(double) fs) {
    final status = _focusedMonth.month == 5 ? _dayStatuses[_selectedDay.day] : null;
    final isFuture = _selectedDay.isAfter(DateTime(2026, 5, 26));
    
    if (status == null) {
      return Container(
        padding: EdgeInsets.all(scaleF(20)),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(
              isFuture ? Icons.schedule_outlined : Icons.remove_circle_outline,
              color: CustomersLoginThemeView.textGrey,
              size: 40,
            ),
            SizedBox(height: scaleF(10)),
            Text(
              isFuture ? 'No Deliveries Scheduled' : 'No Deliveries Happened',
              style: GoogleFonts.montserrat(
                fontSize: fs(14),
                fontWeight: FontWeight.bold,
                color: CustomersLoginThemeView.textGrey,
              ),
            ),
            SizedBox(height: scaleF(4)),
            Text(
              isFuture
                  ? 'No deliveries scheduled for this upcoming date yet.'
                  : 'No delivery records found for this date.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: fs(12),
                color: CustomersLoginThemeView.textGrey.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }
    
    if (status == 'cancelled') {
      return Container(
        padding: EdgeInsets.all(scaleF(20)),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            const Icon(Icons.cancel_outlined, color: Color(0xFFEF5350), size: 40),
            SizedBox(height: scaleF(10)),
            Text(
              'Delivery Cancelled',
              style: GoogleFonts.montserrat(
                fontSize: fs(14),
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF5350),
              ),
            ),
            SizedBox(height: scaleF(4)),
            Text(
              'No deliveries scheduled for this date due to suspension.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: fs(12),
                color: CustomersLoginThemeView.textGrey,
              ),
            ),
          ],
        ),
      );
    }

    final morningTime = '06:00 - 08:30';
    final eveningTime = '17:30 - 20:00';
    final quantity = widget.booking.configSummary.firstWhere((line) => line.contains('Quantity:'), orElse: () => 'Quantity: 500ml').replaceAll('Quantity:', '').trim();

    return Column(
      children: [
        if (isMorning || isBoth)
          _timelineRow(
            time: morningTime,
            deliveryTime: '07:15 AM',
            title: 'Morning Delivery',
            description: '$quantity Cow Milk delivered',
            tag: 'Morning',
            tagColor: const Color(0xFFEC407A), // Hot Pink
            isDelivered: status != 'adjusted',
            isAdjusted: status == 'adjusted',
            scaleF: scaleF,
            fs: fs,
          ),
        if (isEvening || isBoth)
          _timelineRow(
            time: eveningTime,
            deliveryTime: status == 'adjusted' ? '06:45 PM (Pending)' : '06:12 PM',
            title: 'Evening Delivery',
            description: '$quantity Cow Milk ' + (status == 'adjusted' ? 'scheduled' : 'delivered'),
            tag: 'Evening',
            tagColor: const Color(0xFFFBC02D), // Mustard Yellow
            isDelivered: status == 'delivered',
            isAdjusted: status == 'adjusted',
            scaleF: scaleF,
            fs: fs,
            isLast: true,
          ),
      ],
    );
  }

  Widget _timelineRow({
    required String time,
    required String deliveryTime,
    required String title,
    required String description,
    required String tag,
    required Color tagColor,
    required bool isDelivered,
    required bool isAdjusted,
    required double Function(double) scaleF,
    required double Function(double) fs,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time Indicator
          SizedBox(
            width: scaleF(80),
            child: Padding(
              padding: EdgeInsets.only(top: scaleF(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time.split(' ')[0],
                    style: GoogleFonts.montserrat(
                      fontSize: fs(13),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                  Text(
                    'Time Slot',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(10),
                      color: CustomersLoginThemeView.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Timeline Node Indicator
          Column(
            children: [
              Container(
                width: scaleF(14),
                height: scaleF(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDelivered ? const Color(0xFF4CAF50) : (isAdjusted ? const Color(0xFFFF9800) : Colors.grey),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          SizedBox(width: scaleF(16)),

          // Timeline Card Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: scaleF(16)),
              child: Container(
                padding: EdgeInsets.all(scaleF(14)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.3)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(9),
                              fontWeight: FontWeight.bold,
                              color: tagColor,
                            ),
                          ),
                        ),
                        Text(
                          isDelivered ? 'Delivered at $deliveryTime' : (isAdjusted ? 'Rescheduled' : 'Pending'),
                          style: GoogleFonts.montserrat(
                            fontSize: fs(10),
                            fontWeight: FontWeight.bold,
                            color: isDelivered ? const Color(0xFF4CAF50) : (isAdjusted ? const Color(0xFFFF9800) : CustomersLoginThemeView.textGrey),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: scaleF(6)),
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(13),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(2)),
                    Text(
                      description,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        fontWeight: FontWeight.w500,
                        color: CustomersLoginThemeView.textGrey,
                      ),
                    ),
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
