import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../viewmodels/bottles_viewmodel.dart';
import '../models/bottle_collection_model.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/services/haptic_service.dart';

class BottlesHistoryView extends StatefulWidget {
  const BottlesHistoryView({super.key});

  @override
  State<BottlesHistoryView> createState() => _BottlesHistoryViewState();
}

class _BottlesHistoryViewState extends State<BottlesHistoryView> {
  String _selectedMonth = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][DateTime.now().month - 1];
  DateTime _selectedDate = DateTime.now();
  final ScrollController _calendarScrollController = ScrollController();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    context.read<BottlesViewModel>().add(const LoadBottleCollections());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _scrollToSelectedDate() {
    if (!_calendarScrollController.hasClients) return;
    final scaleF = (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final dayIndex = _selectedDate.day - 1;
    final targetOffset = dayIndex * scaleF(54.0);
    _calendarScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  int _monthIndex(String monthAbbr) {
    return _months.indexOf(monthAbbr) + 1;
  }

  List<BottleCollectionModel> _applyFilters(List<BottleCollectionModel> collections) {
    return collections.where((c) {
      if (!c.isCollected) return false;
      
      if (c.collectionDate == null ||
          c.collectionDate!.year != _selectedDate.year ||
          c.collectionDate!.month != _selectedDate.month ||
          c.collectionDate!.day != _selectedDate.day) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) {
      final aDate = a.collectionDate ?? DateTime(2000);
      final bDate = b.collectionDate ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'N/A';
    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    return '$hour:$minute $period';
  }

  Widget _buildCalendarStrip(List<BottleCollectionModel> allCollected, Function scaleF, Function fs) {
    final int year = DateTime.now().year;
    final int month = _monthIndex(_selectedMonth);
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Container(
      height: scaleF(80),
      margin: EdgeInsets.only(top: scaleF(8)),
      child: ListView.builder(
        controller: _calendarScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          final day = index + 1;
          final date = DateTime(year, month, day);
          final isSelected = _selectedDate.year == date.year && _selectedDate.month == date.month && _selectedDate.day == day;

          final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final weekdayStr = weekdays[date.weekday - 1];

          final hasOrders = allCollected.any((o) => 
            o.collectionDate != null && 
            o.collectionDate!.year == date.year && 
            o.collectionDate!.month == date.month && 
            o.collectionDate!.day == date.day
          );

          Color dotColor = hasOrders ? PaalvandiTheme.deliveredGreen : Colors.transparent;

          return GestureDetector(
            onTap: () {
              HapticService.light();
              setState(() {
                _selectedDate = date;
              });
            },
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
                      color: isSelected ? PaalvandiTheme.primaryBlue : PaalvandiTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: scaleF(4)),
                  Container(
                    width: scaleF(32),
                    height: scaleF(32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? PaalvandiTheme.primaryBlue : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.black.withOpacity(0.15),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: PaalvandiTheme.primaryBlue.withOpacity(0.3),
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

  Widget _buildFilterDropdown(Function scaleF, Function fs) {
    final hPadding = ResponsiveHelper.horizontalPadding(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: scaleF(12), vertical: scaleF(4)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PaalvandiTheme.cardBorderLight, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedMonth,
                  icon: Icon(Icons.keyboard_arrow_down, color: PaalvandiTheme.primaryBlue, size: scaleF(20)),
                  items: _months.map((m) {
                    return DropdownMenuItem<String>(
                      value: m,
                      child: Text(
                        m,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      HapticService.light();
                      setState(() {
                        _selectedMonth = val;
                        final year = DateTime.now().year;
                        final month = _monthIndex(val);
                        _selectedDate = DateTime(year, month, 1);
                      });
                      _scrollToSelectedDate();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BottleCollectionModel col, Function scaleF, Function fs) {
    return Container(
      padding: EdgeInsets.all(scaleF(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  col.customerName,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.w900,
                    color: PaalvandiTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(4)),
                decoration: PaalvandiTheme.statusBadgeDecoration(PaalvandiTheme.statusSuccess),
                child: Text(
                  'COLLECTED',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(9),
                    fontWeight: FontWeight.bold,
                    color: PaalvandiTheme.statusSuccess,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(4)),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: scaleF(12), color: PaalvandiTheme.textSecondary),
              SizedBox(width: scaleF(4)),
              Text(
                'Collected: ${_formatDate(col.collectionDate)} • ${_formatTime(col.collectionDate)}',
                style: GoogleFonts.montserrat(
                  fontSize: fs(11),
                  fontWeight: FontWeight.w500,
                  color: PaalvandiTheme.textSecondary,
                ),
              ),
            ],
          ),
          if (col.requestDate != null) ...[
            SizedBox(height: scaleF(4)),
            Row(
              children: [
                Icon(Icons.event_note_outlined, size: scaleF(12), color: PaalvandiTheme.textSecondary),
                SizedBox(width: scaleF(4)),
                Text(
                  'Requested: ${_formatDate(col.requestDate)} • ${_formatTime(col.requestDate)}',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(11),
                    fontWeight: FontWeight.w500,
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: scaleF(12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: scaleF(16), color: PaalvandiTheme.primaryBlue),
              SizedBox(width: scaleF(8)),
              Expanded(
                child: Text(
                  col.address,
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
          SizedBox(height: scaleF(16)),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(scaleF(12)),
                decoration: BoxDecoration(
                  color: PaalvandiTheme.bgCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COLLECTED BOTTLES',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(9),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: scaleF(4)),
                    Row(
                      children: [
                        Icon(Icons.recycling_outlined, size: scaleF(18), color: PaalvandiTheme.primaryBlue),
                        SizedBox(width: scaleF(6)),
                        Text(
                          '${col.pendingBottles} Glass Bottles',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(13),
                            fontWeight: FontWeight.w900,
                            color: PaalvandiTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: scaleF(12)),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(scaleF(12)),
                  decoration: BoxDecoration(
                    color: PaalvandiTheme.bgCream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REFUNDED AMOUNT',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(9),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: scaleF(4)),
                      Row(
                        children: [
                          Icon(Icons.currency_rupee, size: scaleF(16), color: PaalvandiTheme.accentGreen),
                          Expanded(
                            child: Text(
                              '₹${col.depositValue.toStringAsFixed(0)}',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(13),
                                fontWeight: FontWeight.w900,
                                color: PaalvandiTheme.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs = (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: PaalvandiTheme.bgCream,
      appBar: AppBar(
        backgroundColor: PaalvandiTheme.bgCream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: PaalvandiTheme.textDark, size: scaleF(24)),
          onPressed: () {
            HapticService.light();
            context.pop();
          },
        ),
        title: Text(
          'Bottle Returns History',
          style: GoogleFonts.montserrat(
            fontSize: fs(18),
            fontWeight: FontWeight.bold,
            color: PaalvandiTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<BottlesViewModel, BottlesState>(
        builder: (context, state) {
          final allCollected = state.collections.where((c) => c.isCollected).toList();
          final filteredCollections = _applyFilters(allCollected);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterDropdown(scaleF, fs),
              _buildCalendarStrip(allCollected, scaleF, fs),
              Expanded(
                child: filteredCollections.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset('assets/animations/noitemincart.json', height: scaleF(120)),
                            SizedBox(height: scaleF(16)),
                            Text(
                              'No collected bottles on ${_formatDate(_selectedDate)}',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(14),
                                fontWeight: FontWeight.bold,
                                color: PaalvandiTheme.textDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
                        itemCount: filteredCollections.length,
                        separatorBuilder: (_, __) => SizedBox(height: scaleF(12)),
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(filteredCollections[index], scaleF, fs);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
