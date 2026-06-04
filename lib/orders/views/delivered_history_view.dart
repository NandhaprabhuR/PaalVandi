import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../models/daily_order_model.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/services/haptic_service.dart';

class DeliveredHistoryView extends StatefulWidget {
  const DeliveredHistoryView({super.key});

  @override
  State<DeliveredHistoryView> createState() => _DeliveredHistoryViewState();
}

class _DeliveredHistoryViewState extends State<DeliveredHistoryView> {
  DateTime _selectedDate = DateTime.now();
  String _selectedStatusFilter = 'All'; // 'All' | 'Delivered' | 'Cancelled' | 'Assigned'

  String _getProductImageUrl(String name) {
    if (name.contains('Milk')) {
      return 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&q=80&w=200';
    } else if (name.contains('Curd')) {
      return 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&q=80&w=200';
    } else if (name.contains('Buttermilk')) {
      return 'https://images.unsplash.com/photo-1528498033973-3c07f7b4c26a?auto=format&fit=crop&q=80&w=200';
    }
    return 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&q=80&w=200';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return PaalvandiTheme.deliveredGreen;
      case 'Cancelled':
      case 'Rejected':
        return PaalvandiTheme.statusError;
      case 'Assigned':
      case 'Accepted':
        return PaalvandiTheme.primaryBlue;
      default:
        return PaalvandiTheme.textMuted;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'Delivered':
        return const Color(0xFFE8F5E9);
      case 'Cancelled':
      case 'Rejected':
        return const Color(0xFFFFEBEE);
      case 'Assigned':
      case 'Accepted':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  List<DailyOrderModel> _getOrdersForDate(DateTime date, List<DailyOrderModel> allOrders) {
    // Usually we would filter by date, but since mock orders are few,
    // let's just pretend all delivered/cancelled orders belong to the selected date
    // for demonstration purposes if it's not today.
    final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;
    if (isToday) {
      return allOrders;
    } else {
      // Mock historical data: flip some statuses or just return delivered/cancelled
      return allOrders.map((o) {
        if (o.status == 'Assigned' || o.status == 'Accepted') {
          return o.copyWith(status: 'Delivered');
        }
        return o;
      }).toList();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    HapticService.light();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: PaalvandiTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: PaalvandiTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      HapticService.medium();
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildHistoryStatItem(String label, String value, IconData icon, Function scaleF, Function fs, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: scaleF(18), color: color),
          SizedBox(height: scaleF(4)),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: fs(9),
              fontWeight: FontWeight.w600,
              color: PaalvandiTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: fs(12),
              fontWeight: FontWeight.bold,
              color: PaalvandiTheme.textDark,
            ),
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

    // Dynamic date text
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateDisplay = '${weekdays[_selectedDate.weekday - 1]}, ${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            'Orders History',
            style: GoogleFonts.montserrat(
              fontSize: fs(16),
              fontWeight: FontWeight.bold,
              color: PaalvandiTheme.deliveredGreen,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<OrdersViewModel, OrdersState>(
          builder: (context, state) {
            final dateOrders = _getOrdersForDate(_selectedDate, state.orders);

            int totalOrders = dateOrders.length;
            int delivered = dateOrders.where((o) => o.status == 'Delivered').length;
            int cancelled = dateOrders.where((o) => o.status == 'Cancelled' || o.status == 'Rejected').length;

            final morningOrders = dateOrders.where((o) => o.orderTime.hour < 12).toList();
            final eveningOrders = dateOrders.where((o) => o.orderTime.hour >= 12).toList();

            return Column(
              children: [
                // ─── DATE SELECTOR BAR ───
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(6)),
                    padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(12)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month, color: PaalvandiTheme.primaryBlue, size: scaleF(20)),
                            SizedBox(width: scaleF(12)),
                            Text(
                              dateDisplay,
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.bold,
                                color: PaalvandiTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(scaleF(6)),
                          decoration: BoxDecoration(
                            color: PaalvandiTheme.bgLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Icon(Icons.edit_calendar, size: scaleF(16), color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── TOP SUMMARY CARD ───
                Container(
                  margin: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(6)),
                  padding: EdgeInsets.all(scaleF(12)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHistoryStatItem('Total Orders', '$totalOrders', Icons.receipt_long, scaleF, fs, PaalvandiTheme.primaryBlue),
                      Container(width: 1, height: scaleF(30), color: PaalvandiTheme.dividerColor),
                      _buildHistoryStatItem('Delivered', '$delivered', Icons.check_circle_outline, scaleF, fs, PaalvandiTheme.deliveredGreen),
                      Container(width: 1, height: scaleF(30), color: PaalvandiTheme.dividerColor),
                      _buildHistoryStatItem('Cancelled', '$cancelled', Icons.cancel_outlined, scaleF, fs, PaalvandiTheme.statusError),
                    ],
                  ),
                ),

                // ─── FILTER DROPDOWN BAR ───
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(4)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Orders List',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.deliveredGreen,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: scaleF(12)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatusFilter,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                            style: GoogleFonts.montserrat(
                              fontSize: fs(11),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                HapticService.light();
                                setState(() {
                                  _selectedStatusFilter = newValue;
                                });
                              }
                            },
                            items: <String>['All', 'Delivered', 'Cancelled', 'Assigned']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── GOOGLE PAY FLAT TAB BAR ───
                Container(
                  color: PaalvandiTheme.cardWhite,
                  width: double.infinity,
                  child: Column(
                    children: [
                      TabBar(
                        onTap: (index) => HapticService.light(),
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
                        tabs: const [
                          Tab(text: 'Morning'),
                          Tab(text: 'Evening'),
                        ],
                      ),
                      Container(
                        height: 1.0,
                        color: PaalvandiTheme.cardBorder,
                      ),
                    ],
                  ),
                ),

                // History Tab View content
                Expanded(
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildOrdersList(morningOrders, scaleF, fs, hPadding),
                      _buildOrdersList(eveningOrders, scaleF, fs, hPadding),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    List<DailyOrderModel> orders,
    Function scaleF,
    Function fs,
    double hPadding,
  ) {
    // Filter by dropdown status
    final filteredOrders = orders.where((o) {
      if (_selectedStatusFilter == 'All') return true;
      if (_selectedStatusFilter == 'Delivered') return o.status == 'Delivered';
      if (_selectedStatusFilter == 'Cancelled') return o.status == 'Cancelled' || o.status == 'Rejected';
      if (_selectedStatusFilter == 'Assigned') return o.status == 'Assigned' || o.status == 'Accepted';
      return true;
    }).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(scaleF(20)),
          child: Text(
            'No matching historical orders',
            style: GoogleFonts.montserrat(
              fontSize: fs(12),
              fontWeight: FontWeight.bold,
              color: PaalvandiTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
      itemCount: filteredOrders.length,
      separatorBuilder: (_, __) => SizedBox(height: scaleF(12)),
      itemBuilder: (context, index) {
        return _buildOrderCard(filteredOrders[index], scaleF, fs);
      },
    );
  }

  Widget _buildOrderCard(DailyOrderModel order, Function scaleF, Function fs) {
    final statusColor = _statusColor(order.status);
    final statusBgColor = _statusBgColor(order.status);

    return GestureDetector(
      onTap: () {
        HapticService.light();
        context.push('/order-detail/${order.orderId}');
      },
      child: Container(
        padding: EdgeInsets.all(scaleF(14)),
        decoration: BoxDecoration(
          color: statusBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: PaalvandiTheme.primaryBlue, size: scaleF(18)),
                    SizedBox(width: scaleF(6)),
                    Text(
                      '${order.orderId} • ${order.orderTime.hour.toString().padLeft(2, '0')}:${order.orderTime.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(13),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(4)),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 0.5),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: fs(9),
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleF(8)),

            // Customer details
            Row(
              children: [
                Icon(Icons.person_outline, size: scaleF(14), color: PaalvandiTheme.primaryBlue),
                SizedBox(width: scaleF(6)),
                Expanded(
                  child: Text(
                    '${order.customerName} • +91 ${order.customerPhone}',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(11),
                      fontWeight: FontWeight.bold,
                      color: PaalvandiTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleF(4)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: scaleF(14), color: PaalvandiTheme.primaryBlue),
                SizedBox(width: scaleF(6)),
                Expanded(
                  child: Text(
                    order.address,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(10),
                      color: PaalvandiTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleF(12)),
            Divider(color: PaalvandiTheme.dividerColor, height: 1),
            SizedBox(height: scaleF(12)),

            // Products and Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ITEMS',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(8),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.textMuted,
                        ),
                      ),
                      SizedBox(height: scaleF(2)),
                      Text(
                        order.products.map((p) => '${p.quantity}x ${p.name}').join(', '),
                        style: GoogleFonts.montserrat(
                          fontSize: fs(10),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: scaleF(12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(8),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textMuted,
                      ),
                    ),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.w900,
                        color: PaalvandiTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

