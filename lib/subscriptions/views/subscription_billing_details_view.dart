import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/subscriptions_viewmodel.dart';
import '../models/delivery_ledger_entry.dart';
import '../services/subscription_billing_engine.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/services/haptic_service.dart';

class SubscriptionBillingDetailsView extends StatefulWidget {
  final String subscriptionId;

  const SubscriptionBillingDetailsView({super.key, required this.subscriptionId});

  @override
  State<SubscriptionBillingDetailsView> createState() => _SubscriptionBillingDetailsViewState();
}

class _SubscriptionBillingDetailsViewState extends State<SubscriptionBillingDetailsView> {
  int _selectedMonth = 6; // June by default
  final int _selectedYear = 2026;
  int _selectedDay = 3; // Default to 3rd day of the month

  final ScrollController _scrollController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  bool _isScrollingToDay = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadDetails();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _calendarScrollController.dispose();
    super.dispose();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return 'Unknown';
  }

  void _onScroll() {
    if (_isScrollingToDay || !_scrollController.hasClients) return;

    double scaleF(num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final headerHeight = scaleF(240);
    final itemHeight = scaleF(155);

    final offset = _scrollController.offset;
    int calculatedDay = 1;
    if (offset >= headerHeight) {
      calculatedDay = ((offset - headerHeight) / itemHeight).round() + 1;
    }

    final state = context.read<SubscriptionsViewModel>().state;
    final stmt = state.activeStatement;
    if (stmt != null) {
      final clampedDay = calculatedDay.clamp(1, stmt.calendarDays);
      if (_selectedDay != clampedDay) {
        setState(() {
          _selectedDay = clampedDay;
        });
        _centerCalendarDay(clampedDay, scaleF);
      }
    }
  }

  void _centerCalendarDay(int day, Function scaleF) {
    if (_calendarScrollController.hasClients) {
      final itemWidth = scaleF(54); // cell width (46) + margin (8)
      final screenWidth = MediaQuery.of(context).size.width;
      final targetOffset = (day - 1) * itemWidth - (screenWidth / 2) + (itemWidth / 2);

      _calendarScrollController.animateTo(
        targetOffset.clamp(0.0, _calendarScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToDay(int day, Function scaleF) {
    _isScrollingToDay = true;
    setState(() {
      _selectedDay = day;
    });
    _centerCalendarDay(day, scaleF);

    final headerHeight = scaleF(240);
    final itemHeight = scaleF(155);
    final targetOffset = headerHeight + (day - 1) * itemHeight;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ).then((_) {
        _isScrollingToDay = false;
      });
    }
  }

  void _loadDetails() {
    context.read<SubscriptionsViewModel>().add(
          LoadBillingDetails(widget.subscriptionId, _selectedMonth, _selectedYear),
        );
  }

  void _showMonthlySummaryBottomSheet(BuildContext context, BillingStatement stmt, Function scaleF, Function fs) {
    HapticService.medium();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Colors.black, width: 2),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(scaleF(20), scaleF(20), scaleF(20), scaleF(30)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: scaleF(45),
                  height: scaleF(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: scaleF(16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Bill Statement',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(15),
                      fontWeight: FontWeight.bold,
                      color: PaalvandiTheme.deliveredGreen,
                    ),
                  ),
                  _buildPaymentBadge(stmt.paymentStatus, scaleF, fs),
                ],
              ),
              Text(
                'Summary for ${stmt.monthName} ${stmt.year}',
                style: GoogleFonts.montserrat(
                  fontSize: fs(11),
                  color: PaalvandiTheme.textSecondary,
                ),
              ),
              SizedBox(height: scaleF(14)),
              const Divider(color: PaalvandiTheme.dividerColor),
              SizedBox(height: scaleF(8)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBottomSummaryCell('Calendar Days', '${stmt.calendarDays}', scaleF, fs),
                  _buildBottomSummaryCell('Delivered Days', '${stmt.deliveredDays}', scaleF, fs),
                  _buildBottomSummaryCell('Vacation Days', '${stmt.vacationDays}', scaleF, fs),
                  _buildBottomSummaryCell('Paused/Skip', '${stmt.pausedDays + stmt.skippedDays}', scaleF, fs),
                ],
              ),
              SizedBox(height: scaleF(14)),
              const Divider(color: PaalvandiTheme.dividerColor),
              SizedBox(height: scaleF(12)),

              _buildQtyRow('Delivered Qty Volume', '${stmt.deliveredQuantity.toStringAsFixed(1)}L', scaleF, fs),
              SizedBox(height: scaleF(6)),
              _buildQtyRow('Milk Rate Per Liter', '₹${stmt.ratePerLiter.toStringAsFixed(0)}/L', scaleF, fs),
              SizedBox(height: scaleF(6)),
              _buildQtyRow('Total Monthly Bill', '₹${stmt.monthlyBill.toStringAsFixed(0)}', scaleF, fs),
              SizedBox(height: scaleF(6)),
              _buildQtyRow('Advance Paid', '₹${stmt.advancePaid.toStringAsFixed(0)}', scaleF, fs),
              SizedBox(height: scaleF(6)),
              const Divider(color: PaalvandiTheme.dividerColor),
              SizedBox(height: scaleF(6)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stmt.remainingBalance >= 0 ? 'Remaining Balance Due' : 'Advance Credit Balance',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(12),
                      fontWeight: FontWeight.w900,
                      color: PaalvandiTheme.textDark,
                    ),
                  ),
                  Text(
                    '₹${stmt.remainingBalance.abs().toStringAsFixed(0)}',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.w900,
                      color: stmt.remainingBalance > 0 ? PaalvandiTheme.statusWarning : PaalvandiTheme.deliveredGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSummaryCell(String label, String value, Function scaleF, Function fs) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: fs(9),
            fontWeight: FontWeight.w600,
            color: PaalvandiTheme.textSecondary,
          ),
        ),
        SizedBox(height: scaleF(4)),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: fs(12),
            fontWeight: FontWeight.w900,
            color: PaalvandiTheme.textDark,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double scaleF(num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    double fs(num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: PaalvandiTheme.bgCream,
      appBar: AppBar(
        backgroundColor: PaalvandiTheme.bgCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PaalvandiTheme.textDark),
          onPressed: () {
            HapticService.light();
            Navigator.pop(context);
          },
        ),
        title: BlocBuilder<SubscriptionsViewModel, SubscriptionsState>(
          builder: (context, state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month selector triggering PopupMenu
                PopupMenuButton<int>(
                  initialValue: _selectedMonth,
                  offset: const Offset(0, 40),
                  onSelected: (int newValue) {
                    HapticService.light();
                    setState(() {
                      _selectedMonth = newValue;
                      final maxDays = DateTime(_selectedYear, newValue + 1, 0).day;
                      if (_selectedDay > maxDays) {
                        _selectedDay = maxDays;
                      }
                    });
                    _loadDetails();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 1, child: Text('Jan')),
                    PopupMenuItem(value: 2, child: Text('Feb')),
                    PopupMenuItem(value: 3, child: Text('Mar')),
                    PopupMenuItem(value: 4, child: Text('Apr')),
                    PopupMenuItem(value: 5, child: Text('May')),
                    PopupMenuItem(value: 6, child: Text('Jun')),
                    PopupMenuItem(value: 7, child: Text('Jul')),
                    PopupMenuItem(value: 8, child: Text('Aug')),
                    PopupMenuItem(value: 9, child: Text('Sep')),
                    PopupMenuItem(value: 10, child: Text('Oct')),
                    PopupMenuItem(value: 11, child: Text('Nov')),
                    PopupMenuItem(value: 12, child: Text('Dec')),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getMonthName(_selectedMonth),
                        style: GoogleFonts.montserrat(
                          fontSize: fs(22),
                          fontWeight: FontWeight.w900,
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                      SizedBox(width: scaleF(4)),
                      Icon(Icons.keyboard_arrow_down, size: scaleF(18), color: Colors.black),
                    ],
                  ),
                ),
                
                // Plus circular button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticService.medium();
                        context.push('/subscriptions/billing-history/${widget.subscriptionId}');
                      },
                      child: Container(
                        padding: EdgeInsets.all(scaleF(6)),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, size: scaleF(16), color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        ),
      ),
      body: BlocBuilder<SubscriptionsViewModel, SubscriptionsState>(
        builder: (context, state) {
          if (state.isBillingLoading || state.activeStatement == null) {
            return Center(child: CircularProgressIndicator(color: PaalvandiTheme.primaryBlue));
          }

          final stmt = state.activeStatement!;

          return ListView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
            children: [
              // ─── CUSTOMER HEADER CARD ───
              Container(
                padding: EdgeInsets.all(scaleF(14)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stmt.customerName,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(15),
                              fontWeight: FontWeight.w900,
                              color: PaalvandiTheme.deliveredGreen,
                            ),
                          ),
                          SizedBox(height: scaleF(2)),
                          Text(
                            '+91 ${stmt.phone}  •  ${stmt.subscriptionType} Subscription',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(10),
                              fontWeight: FontWeight.w600,
                              color: PaalvandiTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.history, color: PaalvandiTheme.primaryBlue),
                      tooltip: 'View History',
                      onPressed: () {
                        HapticService.light();
                        context.push('/subscriptions/billing-history/${widget.subscriptionId}');
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: scaleF(14)),

              // ─── HORIZONTAL CALENDAR STRIP ───
              _buildCalendarStrip(stmt, scaleF, fs),
              SizedBox(height: scaleF(14)),

              // ─── MONTHLY SUMMARY STATEMENT TRIGGER PILL ───
              GestureDetector(
                onTap: () => _showMonthlySummaryBottomSheet(context, stmt, scaleF, fs),
                child: Container(
                  height: scaleF(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assessment_outlined, size: scaleF(16), color: Colors.white),
                      SizedBox(width: scaleF(8)),
                      Text(
                        'Monthly Statement Summary',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: scaleF(16)),

              Text(
                'Monthly Timeline Log:',
                style: GoogleFonts.montserrat(
                  fontSize: fs(12),
                  fontWeight: FontWeight.bold,
                  color: PaalvandiTheme.deliveredGreen,
                ),
              ),
              SizedBox(height: scaleF(12)),

              // ─── VERTICAL TIMELINE LIST OF ALL DAYS ───
              ...List.generate(stmt.calendarDays, (index) {
                final day = index + 1;
                final date = DateTime(_selectedYear, _selectedMonth, day);
                final isSelected = _selectedDay == day;

                final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final weekdayStr = weekdays[date.weekday - 1];

                final entry = stmt.monthEntries.firstWhere(
                  (e) => e.date.day == day,
                  orElse: () => DeliveryLedgerEntry(
                    id: '',
                    subscriptionId: widget.subscriptionId,
                    date: date,
                    status: 'Pending',
                    quantityMorning: 0,
                    quantityEvening: 0,
                    ratePerLiter: stmt.ratePerLiter,
                  ),
                );

                return Padding(
                  padding: EdgeInsets.only(bottom: scaleF(14)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Timeline Indicator
                      SizedBox(
                        width: scaleF(45),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _scrollToDay(day, scaleF),
                              child: Container(
                                width: scaleF(32),
                                height: scaleF(32),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFEC407A) : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.black : Colors.black.withOpacity(0.15),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  day < 10 ? '0$day' : '$day',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(11),
                                    fontWeight: FontWeight.w900,
                                    color: isSelected ? Colors.white : PaalvandiTheme.textDark,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: scaleF(4)),
                            Text(
                              weekdayStr,
                              style: GoogleFonts.montserrat(
                                  fontSize: fs(9),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? const Color(0xFFEC407A) : PaalvandiTheme.textSecondary,
                                ),
                            ),
                            SizedBox(height: scaleF(6)),
                            if (day < stmt.calendarDays)
                              Column(
                                children: [
                                  Container(
                                    width: scaleF(1.5),
                                    height: scaleF(30),
                                    color: Colors.black.withOpacity(0.15),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: scaleF(2)),
                                    child: Icon(
                                      Icons.unfold_more,
                                      size: scaleF(14),
                                      color: Colors.black.withOpacity(0.25),
                                    ),
                                  ),
                                  Container(
                                    width: scaleF(1.5),
                                    height: scaleF(30),
                                    color: Colors.black.withOpacity(0.15),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: scaleF(10)),
                      
                      // Right Day Card
                      Expanded(
                        child: _buildDayCard(day, date, entry, stmt, scaleF, fs),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarStrip(BillingStatement stmt, Function scaleF, Function fs) {
    return SizedBox(
      height: scaleF(72),
      child: ListView.builder(
        controller: _calendarScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: stmt.calendarDays,
        itemBuilder: (context, index) {
          final day = index + 1;
          final date = DateTime(_selectedYear, _selectedMonth, day);
          final isSelected = _selectedDay == day;

          final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final weekdayStr = weekdays[date.weekday - 1];

          final entry = stmt.monthEntries.firstWhere(
            (e) => e.date.day == day,
            orElse: () => DeliveryLedgerEntry(
              id: '',
              subscriptionId: widget.subscriptionId,
              date: date,
              status: 'Pending',
              quantityMorning: 0,
              quantityEvening: 0,
              ratePerLiter: stmt.ratePerLiter,
            ),
          );

          Color dotColor = Colors.transparent;
          switch (entry.status) {
            case 'Delivered':
              dotColor = PaalvandiTheme.deliveredGreen;
              break;
            case 'Vacation':
              dotColor = PaalvandiTheme.statusError;
              break;
            case 'Paused':
              dotColor = PaalvandiTheme.statusWarning;
              break;
            case 'Customer Skip':
            case 'Company Skip':
              dotColor = Colors.purple;
              break;
            case 'Failed Delivery':
              dotColor = Colors.red;
              break;
          }

          return GestureDetector(
            onTap: () => _scrollToDay(day, scaleF),
            child: Container(
              width: scaleF(46),
              margin: EdgeInsets.only(right: scaleF(8)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdayStr,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(9),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? const Color(0xFFEC407A) : PaalvandiTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: scaleF(4)),
                  Container(
                    width: scaleF(32),
                    height: scaleF(32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEC407A) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.black.withOpacity(0.15),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFEC407A).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      '$day',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12),
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : PaalvandiTheme.textDark,
                      ),
                    ),
                  ),
                  SizedBox(height: scaleF(4)),
                  Container(
                    width: scaleF(5),
                    height: scaleF(5),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverlapAvatars(DeliveryLedgerEntry entry, BillingStatement stmt, Function scaleF, Function fs) {
    final customerInitials = stmt.customerName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final double avatarSize = scaleF(24);
    final double overlap = scaleF(8);

    return SizedBox(
      height: avatarSize,
      width: avatarSize * 3 - overlap * 2,
      child: Stack(
        children: [
          // Customer Initials Avatar
          Positioned(
            left: 0,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: PaalvandiTheme.primaryBlue.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.2),
              ),
              alignment: Alignment.center,
              child: Text(
                customerInitials,
                style: GoogleFonts.montserrat(
                  fontSize: fs(7),
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // Delivery Agent Initials Avatar (Ravi Kumar = RK)
          Positioned(
            left: avatarSize - overlap,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.2),
              ),
              alignment: Alignment.center,
              child: Text(
                'RK',
                style: GoogleFonts.montserrat(
                  fontSize: fs(7),
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          // Product Milk Bottle Icon
          Positioned(
            left: (avatarSize - overlap) * 2,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.2),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.local_drink_outlined,
                size: scaleF(10),
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
    int day,
    DateTime dayDate,
    DeliveryLedgerEntry entry,
    BillingStatement stmt,
    Function scaleF,
    Function fs,
  ) {
    final dayStatus = entry.status;

    double qty = entry.quantityMorning + entry.quantityEvening;
    if (stmt.subscriptionType == 'Smart') {
      if (widget.subscriptionId == 'SUB-VAD-2') {
        final smartQtys = {
          1: 1.0, // Mon
          2: 2.0, // Tue
          3: 1.0, // Wed
          4: 0.5, // Thu
          5: 1.0, // Fri
          6: 2.0, // Sat
          7: 0.0, // Sun
        };
        qty = smartQtys[dayDate.weekday] ?? 0.0;
      } else {
        final weekday = dayDate.weekday;
        qty = (weekday == 7) ? 0.0 : (weekday % 2 == 0 ? 2.0 : 1.0);
      }
    } else if (stmt.subscriptionType == 'Event') {
      qty = 50.0;
    }

    Color tagColor;
    Color tagBgColor;
    Color cardBgColor;
    IconData statusIcon;
    String statusLabel = dayStatus;

    switch (dayStatus) {
      case 'Delivered':
        tagColor = Colors.white;
        tagBgColor = const Color(0xFF2E7D32); // Dark Green
        cardBgColor = const Color(0xFFE8F5E9); // Light Green
        statusIcon = Icons.check_circle_outline;
        statusLabel = 'Delivered';
        break;
      case 'Vacation':
        tagColor = Colors.white;
        tagBgColor = const Color(0xFFC62828); // Dark Red
        cardBgColor = const Color(0xFFFFEBEE); // Light Red
        statusIcon = Icons.home_outlined;
        statusLabel = 'Vacation';
        break;
      case 'Paused':
        tagColor = Colors.white;
        tagBgColor = const Color(0xFFEF6C00); // Dark Orange
        cardBgColor = const Color(0xFFFFF3E0); // Light Orange
        statusIcon = Icons.pause_circle_outline;
        statusLabel = 'Paused';
        break;
      case 'Customer Skip':
        tagColor = Colors.white;
        tagBgColor = const Color(0xFF6A1B9A); // Dark Purple
        cardBgColor = const Color(0xFFF3E5F5); // Light Purple
        statusIcon = Icons.skip_next_outlined;
        statusLabel = 'Skipped';
        break;
      case 'Company Skip':
        tagColor = Colors.white;
        tagBgColor = const Color(0xFF455A64); // Dark Blue Grey
        cardBgColor = const Color(0xFFECEFF1); // Light Blue Grey
        statusIcon = Icons.skip_next_outlined;
        statusLabel = 'Skip';
        break;
      case 'Failed Delivery':
        tagColor = Colors.white;
        tagBgColor = const Color(0xFFD32F2F); // Red
        cardBgColor = const Color(0xFFFFEBEE); // Light Red
        statusIcon = Icons.error_outline;
        statusLabel = 'Failed';
        break;
      default:
        tagColor = Colors.black;
        tagBgColor = const Color(0xFFE0E0E0);
        cardBgColor = Colors.white;
        statusIcon = Icons.help_outline;
        statusLabel = 'Pending';
        break;
    }

    double cost = dayStatus == 'Delivered' ? qty * stmt.ratePerLiter : 0.0;

    return Container(
      padding: EdgeInsets.all(scaleF(12)),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3, 3),
            blurRadius: 0,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(4)),
                decoration: BoxDecoration(
                  color: tagBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: tagColor, size: scaleF(10)),
                    SizedBox(width: scaleF(4)),
                    Text(
                      statusLabel.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: fs(8),
                        fontWeight: FontWeight.w900,
                        color: tagColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dayStatus == 'Delivered' ? '07:15' : '--:--',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(9),
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    dayStatus == 'Delivered' ? '08:00' : '--:--',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(9),
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: scaleF(10)),
          Text(
            dayStatus == 'Delivered'
                ? '${qty.toStringAsFixed(1)}L Milk delivered successfully'
                : (dayStatus == 'Vacation'
                    ? 'Vacation suspension - No delivery'
                    : (dayStatus == 'Paused'
                        ? 'Subscription is paused'
                        : (dayStatus == 'Customer Skip' || dayStatus == 'Company Skip'
                            ? 'Skipped delivery for today'
                            : 'Delivery failed - Contact support'))),
            style: GoogleFonts.montserrat(
              fontSize: fs(11),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: scaleF(10)),
          const Divider(color: Colors.black, thickness: 1, height: 1),
          SizedBox(height: scaleF(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverlapAvatars(entry, stmt, scaleF, fs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rate: ₹${stmt.ratePerLiter.toStringAsFixed(0)}/L',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(8),
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    'Total: ₹${cost.toStringAsFixed(0)}',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(11),
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyRow(String label, String value, Function scaleF, Function fs) {
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
