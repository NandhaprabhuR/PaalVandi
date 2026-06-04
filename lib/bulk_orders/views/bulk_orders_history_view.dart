import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../viewmodels/bulk_viewmodel.dart';
import '../models/bulk_order_model.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/services/haptic_service.dart';
import '../../core/widgets/image_carousel_dialog.dart';

class BulkOrdersHistoryView extends StatefulWidget {
  const BulkOrdersHistoryView({super.key});

  @override
  State<BulkOrdersHistoryView> createState() => _BulkOrdersHistoryViewState();
}

class _BulkOrdersHistoryViewState extends State<BulkOrdersHistoryView> {
  String _selectedProduct = 'All Products';
  String _selectedMonth = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][DateTime.now().month - 1];
  DateTime _selectedDate = DateTime.now();
  final ScrollController _calendarScrollController = ScrollController();

  static const List<String> _products = [
    'All Products',
    'Milk',
    'Curd',
    'Buttermilk',
  ];

  static const List<String> _months = [
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

  int _monthIndex(String monthAbbr) {
    return _months.indexOf(monthAbbr) + 1; // 1-based
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

  /// Card background color based on payment status
  Color _historyCardColor(BulkOrderModel order) {
    if (order.paymentStatus == 'Paid Fully') {
      return const Color(0xFFE8F5E9); // Solid Light Green — Fully Paid
    }
    if (order.paymentStatus == 'Partially Paid') {
      return const Color(0xFFFFF3E0); // Solid Light Orange — Partially Paid
    }
    switch (order.orderType) {
      case 'Hotel':
        return const Color(0xFFE3F2FD); // Solid Light Blue — Hotel
      case 'Event':
        return const Color(0xFFFFF8E1); // Solid Light Amber — Event
      case 'Business':
        return const Color(0xFFEDE7F6); // Solid Light Purple — Business
      default:
        return Colors.white;
    }
  }

  /// Status label for the card
  String _statusLabel(BulkOrderModel order) {
    if (order.paymentStatus == 'Paid Fully') return 'PAID FULLY';
    if (order.paymentStatus == 'Partially Paid') return 'PARTIAL PAYMENT';
    if (order.isDelivered) return 'DELIVERED';
    return 'PENDING • ${order.orderType.toUpperCase()}';
  }

  Color _statusLabelColor(BulkOrderModel order) {
    if (order.paymentStatus == 'Paid Fully') return const Color(0xFF2E7D32);
    if (order.paymentStatus == 'Partially Paid') return const Color(0xFFFF8F00);
    if (order.isDelivered) return PaalvandiTheme.statusSuccess;
    return _typeColor(order.orderType);
  }
  Widget _buildCalendarStrip(List<BulkOrderModel> allDeliveredOrders, Function scaleF, Function fs) {
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

          // Check if there are any orders for this day to show a dot
          final hasOrders = allDeliveredOrders.any((o) => 
            o.deliveryDate != null && 
            o.deliveryDate!.year == date.year && 
            o.deliveryDate!.month == date.month && 
            o.deliveryDate!.day == date.day
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

  List<BulkOrderModel> _applyFilters(List<BulkOrderModel> orders) {
    return orders.where((order) {
      // Product filter
      if (_selectedProduct != 'All Products') {
        if (!order.productDetails.toLowerCase().contains(
          _selectedProduct.toLowerCase(),
        )) {
          return false;
        }
      }

      // Date filter
      if (order.deliveryDate == null ||
          order.deliveryDate!.year != _selectedDate.year ||
          order.deliveryDate!.month != _selectedDate.month ||
          order.deliveryDate!.day != _selectedDate.day) {
        return false;
      }

      return true;
    }).toList()..sort((a, b) {
      // Sort by delivery date descending (newest first)
      final aDate = a.deliveryDate ?? DateTime(2000);
      final bDate = b.deliveryDate ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });
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
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (num val) =>
        ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs = (num size) =>
        ResponsiveHelper.scaledFontSize(context, size.toDouble());
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
            context.pop();
          },
        ),
        title: Text(
          'Bulk Orders History',
          style: GoogleFonts.montserrat(
            fontSize: fs(18),
            fontWeight: FontWeight.bold,
            color: PaalvandiTheme.deliveredGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<BulkViewModel, BulkState>(
        builder: (context, state) {
          // Show all delivered orders as history
          final historyOrders = state.orders
              .where((o) => o.isDelivered)
              .toList();
          final filteredOrders = _applyFilters(historyOrders);

          return Column(
            children: [
              // ─── DATE CALENDAR STRIP ───
              _buildCalendarStrip(historyOrders, scaleF, fs),

              // ─── FILTER BAR ───
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: hPadding,
                  vertical: scaleF(8),
                ),
                padding: EdgeInsets.all(scaleF(12)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filters',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.deliveredGreen,
                      ),
                    ),
                    SizedBox(height: scaleF(10)),
                    Row(
                      children: [
                        // Product Filter
                        Expanded(
                          child: _buildFilterDropdown(
                            _selectedProduct,
                            _products,
                            (val) {
                              HapticService.light();
                              setState(() => _selectedProduct = val!);
                            },
                            scaleF,
                            fs,
                          ),
                        ),
                        SizedBox(width: scaleF(8)),
                        // Month Filter
                        Expanded(
                          child: _buildFilterDropdown(
                            _selectedMonth,
                            _months,
                            (val) {
                              HapticService.light();
                              setState(() {
                                _selectedMonth = val!;
                                _selectedDate = DateTime(DateTime.now().year, _monthIndex(val), 1);
                              });
                            },
                            scaleF,
                            fs,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: scaleF(8)),
                    Row(
                      children: [
                        // Reset button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticService.medium();
                              setState(() {
                                _selectedProduct = 'All Products';
                                _selectedMonth = _months[DateTime.now().month - 1];
                                _selectedDate = DateTime.now();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: scaleF(10),
                              ),
                              decoration: BoxDecoration(
                                color: PaalvandiTheme.textSecondary,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Reset Filters',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(10),
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

              // ─── RESULTS COUNT ───
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: hPadding,
                  vertical: scaleF(2),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filteredOrders.length} order${filteredOrders.length != 1 ? 's' : ''} found',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(11),
                      fontWeight: FontWeight.bold,
                      color: PaalvandiTheme.textSecondary,
                    ),
                  ),
                ),
              ),

              // ─── ORDERS LIST ───
              Expanded(
                child: filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/animations/noitemincart.json',
                              height: scaleF(120),
                            ),
                            SizedBox(height: scaleF(16)),
                            Text(
                              'No matching bulk orders',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(14),
                                fontWeight: FontWeight.bold,
                                color: PaalvandiTheme.textDark,
                              ),
                            ),
                            SizedBox(height: scaleF(4)),
                            Text(
                              'Try changing the filters above.',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(11),
                                color: PaalvandiTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: hPadding,
                          vertical: scaleF(8),
                        ),
                        itemCount: filteredOrders.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: scaleF(12)),
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(
                            context,
                            filteredOrders[index],
                            scaleF,
                            fs,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
    Function scaleF,
    Function fs,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: scaleF(10)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: Icon(
            Icons.arrow_drop_down,
            size: scaleF(18),
            color: Colors.black,
          ),
          style: GoogleFonts.montserrat(
            fontSize: fs(10),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String v) {
            return DropdownMenuItem<String>(
              value: v,
              child: Text(v, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    BulkOrderModel order,
    Function scaleF,
    Function fs,
  ) {
    final bool isPaidFully =
        order.paymentStatus == 'Paid Fully' || order.paymentStatus == 'Paid';
    final bool isPartiallyPaid = order.paymentStatus == 'Partially Paid';
    final double remainingAmount = isPartiallyPaid
        ? (order.totalAmount - order.collectedAmount).clamp(0, double.infinity)
        : 0;

    return Container(
      padding: EdgeInsets.all(scaleF(16)),
      decoration: BoxDecoration(
        color: _historyCardColor(order),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Business Name & Status
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
                  color: _statusLabelColor(order),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Text(
                  _statusLabel(order),
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
          SizedBox(height: scaleF(4)),

          // Delivery Date
          // Delivery Date & Order ID
          if (order.deliveryDate != null) ...[
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: scaleF(12),
                  color: PaalvandiTheme.textSecondary,
                ),
                SizedBox(width: scaleF(4)),
                Text(
                  _formatDate(order.deliveryDate),
                  style: GoogleFonts.montserrat(
                    fontSize: fs(9),
                    fontWeight: FontWeight.w600,
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'ID: ${order.id}',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(9),
                    fontWeight: FontWeight.bold,
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleF(8)),
          ],

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

          SizedBox(height: scaleF(4)),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact: ${order.contactPerson}',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        fontWeight: FontWeight.w600,
                        color: PaalvandiTheme.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(2)),
                    Text(
                      'Phone: +91 ${order.phone}',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(10),
                        fontWeight: FontWeight.w500,
                        color: PaalvandiTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: scaleF(8)),
                    // Time badge
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: scaleF(8),
                            vertical: scaleF(3),
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
                                size: scaleF(10),
                                color: Colors.black,
                              ),
                              SizedBox(width: scaleF(3)),
                              Text(
                                'Delivered at ${order.deliveryTime}',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(9),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Address
          SizedBox(height: scaleF(10)),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: scaleF(12)),
          Divider(color: PaalvandiTheme.dividerColor, height: 1),
          SizedBox(height: scaleF(12)),

          // Payment Info Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount: ₹${order.totalAmount.toStringAsFixed(0)}',
                style: GoogleFonts.montserrat(
                  fontSize: fs(10),
                  fontWeight: FontWeight.bold,
                  color: PaalvandiTheme.textDark,
                ),
              ),
              if (isPaidFully && order.paymentStatus == 'Paid')
                Text(
                  'Payment ID: PAY${order.id.replaceAll(RegExp(r'[^0-9]'), '')}',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(9),
                    fontWeight: FontWeight.bold,
                    color: PaalvandiTheme.statusSuccess,
                  ),
                ),
            ],
          ),
          SizedBox(height: scaleF(6)),

          // Paid Fully badge
          if (isPaidFully) ...[
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
                    'PAID FULLY  •  ₹${order.collectedAmount.toStringAsFixed(0)}',
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

          // Partially paid badge
          if (isPartiallyPaid) ...[
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
        ],
      ),
    );
  }
}
