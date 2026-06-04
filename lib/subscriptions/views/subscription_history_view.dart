import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/subscriptions_viewmodel.dart';
import '../models/subscription_delivery_model.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/services/haptic_service.dart';

class SubscriptionHistoryView extends StatefulWidget {
  const SubscriptionHistoryView({super.key});

  @override
  State<SubscriptionHistoryView> createState() => _SubscriptionHistoryViewState();
}

class _SubscriptionHistoryViewState extends State<SubscriptionHistoryView> {
  DateTime _selectedDate = DateTime.now();
  String _selectedStatusFilter = 'All'; // 'All' | 'Delivered' | 'Skipped' | 'Pending'

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

  double _parseVolume(String qtyStr) {
    final milkRegex = RegExp(r'([\d.]+)\s*(L|ml)\s*Milk', caseSensitive: false);
    final match = milkRegex.firstMatch(qtyStr);
    if (match != null) {
      final amount = double.tryParse(match.group(1) ?? '0') ?? 0.0;
      final unit = match.group(2)?.toLowerCase() ?? 'l';
      return unit == 'ml' ? amount / 1000.0 : amount;
    }
    return 0.0;
  }

  List<SubscriptionDeliveryModel> _getMockHistoryForDate(DateTime date, List<SubscriptionDeliveryModel> currentSubs) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return currentSubs;
    }

    final list = <SubscriptionDeliveryModel>[];
    for (final sub in currentSubs) {
      if (sub.status != 'Active') {
        list.add(sub);
        continue;
      }
      
      final isSkipped = sub.customerName.hashCode % 6 == 0;
      final isDelivered = !isSkipped;
      final skipReason = isSkipped ? 'Customer Not Home' : null;
      final bottles = isDelivered ? (sub.pendingBottles > 0 ? (sub.pendingBottles - 1).clamp(0, 10) : 0) : 0;
      
      list.add(sub.copyWith(
        isDelivered: isDelivered,
        isSkipped: isSkipped,
        skipReason: skipReason,
        bottlesCollected: bottles,
      ));
    }
    return list;
  }

  String _getMockTimeForSub(SubscriptionDeliveryModel sub) {
    if (sub.deliveryTime != null) return sub.deliveryTime!;
    final hourOffset = (sub.customerName.hashCode % 2); // 0 or 1
    final minuteOffset = (sub.customerName.hashCode % 60).toString().padLeft(2, '0');
    return sub.timing == 'Morning'
        ? '0${6 + hourOffset}:$minuteOffset AM'
        : '0${5 + hourOffset}:$minuteOffset PM';
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
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: PaalvandiTheme.primaryBlue),
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
    final scaleF =
        (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs =
        (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    // Dynamic date text
    final weekdayStr = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][_selectedDate.weekday - 1];
    final monthStr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][_selectedDate.month - 1];
    final dateDisplay = '$weekdayStr, $monthStr ${_selectedDate.day}, ${_selectedDate.year}';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: PaalvandiTheme.bgCream,
        appBar: AppBar(
          backgroundColor: PaalvandiTheme.bgCream,
          elevation: 0,
          title: Text(
            'Subscription History',
            style: GoogleFonts.montserrat(
              fontSize: fs(16),
              fontWeight: FontWeight.bold,
              color: PaalvandiTheme.deliveredGreen, // Green Heading
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: PaalvandiTheme.textDark),
            onPressed: () {
              HapticService.light();
              Navigator.pop(context);
            },
          ),
        ),
        body: BlocBuilder<SubscriptionsViewModel, SubscriptionsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: CircularProgressIndicator(color: PaalvandiTheme.primaryBlue));
            }

            // Generate history list based on date
            final historySubs = _getMockHistoryForDate(_selectedDate, state.subscriptions);
            
            // Calculate overall stats for the summary card
            final allRoutes = historySubs.map((s) => s.routeName).toSet().toList();
            int totalRoutesAssigned = allRoutes.length;
            int completedRoutes = 0;
            int pendingRoutes = 0;

            for (final routeName in allRoutes) {
              final routeSubs = historySubs.where((s) => s.routeName == routeName && s.status == 'Active').toList();
              if (routeSubs.isEmpty) {
                completedRoutes++;
              } else {
                final allProcessed = routeSubs.every((s) => s.isDelivered || s.isSkipped);
                if (allProcessed) {
                  completedRoutes++;
                } else {
                  pendingRoutes++;
                }
              }
            }

            final morningSubs = historySubs.where((s) => s.timing == 'Morning').toList();
            final eveningSubs = historySubs.where((s) => s.timing == 'Evening').toList();

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
                      _buildHistoryStatItem('Routes Assigned', '$totalRoutesAssigned', Icons.alt_route, scaleF, fs, PaalvandiTheme.primaryBlue),
                      Container(width: 1, height: scaleF(30), color: PaalvandiTheme.dividerColor),
                      _buildHistoryStatItem('Completed', '$completedRoutes', Icons.check_circle_outline, scaleF, fs, PaalvandiTheme.deliveredGreen),
                      Container(width: 1, height: scaleF(30), color: PaalvandiTheme.dividerColor),
                      _buildHistoryStatItem('Pending', '$pendingRoutes', Icons.pending_actions, scaleF, fs, PaalvandiTheme.statusWarning),
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
                        'Deliveries List',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.deliveredGreen, // Green Heading
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
                            items: <String>['All', 'Delivered', 'Skipped', 'Pending']
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
                      _buildHistoryRouteList(morningSubs, scaleF, fs, hPadding),
                      _buildHistoryRouteList(eveningSubs, scaleF, fs, hPadding),
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

  Widget _buildHistoryRouteList(
    List<SubscriptionDeliveryModel> subs,
    Function scaleF,
    Function fs,
    double hPadding,
  ) {
    // Filter the items first based on the selected dropdown status
    final filteredSubs = subs.where((s) {
      if (_selectedStatusFilter == 'All') return true;
      if (_selectedStatusFilter == 'Delivered') return s.isDelivered;
      if (_selectedStatusFilter == 'Skipped') return s.isSkipped;
      if (_selectedStatusFilter == 'Pending') return !s.isDelivered && !s.isSkipped;
      return true;
    }).toList();

    // Group filtered subs by route name
    final routeNames = filteredSubs.map((s) => s.routeName).toSet().toList();

    if (routeNames.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(scaleF(20)),
          child: Text(
            'No matching historical deliveries',
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
      itemCount: routeNames.length,
      separatorBuilder: (_, __) => SizedBox(height: scaleF(16)),
      itemBuilder: (context, index) {
        final routeName = routeNames[index];
        final routeSubs = filteredSubs.where((s) => s.routeName == routeName).toList();
        final activeSubs = routeSubs.where((s) => s.status == 'Active').toList();
        
        final totalCustomers = activeSubs.length;
        final delivered = activeSubs.where((s) => s.isDelivered).length;
        final skipped = activeSubs.where((s) => s.isSkipped).length;

        double routeVolume = 0.0;
        for (final s in activeSubs) {
          routeVolume += _parseVolume(s.quantity);
        }

        if (totalCustomers == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.all(scaleF(12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.alt_route, color: PaalvandiTheme.primaryBlue, size: scaleF(18)),
                      SizedBox(width: scaleF(6)),
                      Text(
                        routeName,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(13),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.deliveredGreen, // Green Heading
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: scaleF(6), vertical: scaleF(2)),
                    decoration: BoxDecoration(
                      color: PaalvandiTheme.bgLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black, width: 0.5),
                    ),
                    child: Text(
                      '${routeVolume.toStringAsFixed(1)}L Total',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(9),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: scaleF(4), bottom: scaleF(8)),
                child: Text(
                  '$totalCustomers Assigned  •  $delivered Delivered  •  $skipped Skipped',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(10),
                    fontWeight: FontWeight.w600,
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
              ),
              const Divider(color: PaalvandiTheme.dividerColor),
              SizedBox(height: scaleF(8)),
              
              // Route Customers list
              ...activeSubs.map((sub) => _buildHistoryCustomerCard(sub, scaleF, fs)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryCustomerCard(SubscriptionDeliveryModel sub, Function scaleF, Function fs) {
    Color cardColor = Colors.white;
    if (sub.isDelivered) {
      cardColor = const Color(0xFFE8F5E9).withOpacity(0.3); // soft green
    } else if (sub.isSkipped) {
      cardColor = const Color(0xFFFFEBEE).withOpacity(0.3); // soft red
    }

    final products = <String>[];
    if (sub.quantity.contains('Milk')) products.add('Milk');
    if (sub.quantity.contains('Curd')) products.add('Curd');
    if (sub.quantity.contains('Buttermilk')) products.add('Buttermilk');
    if (products.isEmpty) products.add('Milk');

    final statusText = sub.isDelivered 
        ? 'Delivered' 
        : (sub.isSkipped ? 'Skipped' : 'Pending');
    final statusColor = sub.isDelivered 
        ? PaalvandiTheme.deliveredGreen 
        : (sub.isSkipped ? PaalvandiTheme.statusError : PaalvandiTheme.statusPending);
    final statusBgColor = sub.isDelivered 
        ? const Color(0xFFE8F5E9) 
        : (sub.isSkipped ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0));

    return Container(
      margin: EdgeInsets.only(bottom: scaleF(10)),
      padding: EdgeInsets.all(scaleF(12)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${sub.subscriptionType} Subscription',
                style: GoogleFonts.montserrat(
                  fontSize: fs(11),
                  fontWeight: FontWeight.w900,
                  color: PaalvandiTheme.textDark,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: scaleF(6), vertical: scaleF(2)),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 0.5),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(8),
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(8)),

          // Customer details (Name and Phone)
          Row(
            children: [
              Icon(Icons.person_outline, size: scaleF(14), color: PaalvandiTheme.primaryBlue),
              SizedBox(width: scaleF(6)),
              Expanded(
                child: Text(
                  '${sub.customerName}  •  +91 ${sub.phone}',
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
                  sub.address,
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
          SizedBox(height: scaleF(8)),

          // Inline product details & payment details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Row(
                children: products.map((prod) {
                  return Container(
                    margin: EdgeInsets.only(right: scaleF(6)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black, width: 0.8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        _getProductImageUrl(prod),
                        width: scaleF(36),
                        height: scaleF(36),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: scaleF(36),
                          height: scaleF(36),
                          color: PaalvandiTheme.bgLight,
                          child: Icon(Icons.water_drop, size: scaleF(14), color: PaalvandiTheme.primaryBlue),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(width: scaleF(6)),
              // Payment balance & collected details
              Expanded(
                child: () {
                  double qty = 1.0;
                  final match = RegExp(r'([\d.]+)\s*(L|ml)').firstMatch(sub.quantity);
                  if (match != null) {
                    qty = double.tryParse(match.group(1) ?? '1.0') ?? 1.0;
                    if (match.group(2)?.toLowerCase() == 'ml') {
                      qty /= 1000.0;
                    }
                  }
                  double rate = sub.subscriptionType == 'Business' ? 55.0 : 60.0;
                  if (sub.id == 'SUB-SAI-5') {
                    qty = 50.0; // Event 50L
                  } else if (sub.id == 'SUB-VAD-3') {
                    qty = 20.0;
                  }
                  double totalProductAmount = qty * rate;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.balanceAmount == 0
                            ? 'paid advance or full amount: ₹${sub.paidAmount.toStringAsFixed(0)}'
                            : 'paid advance: ₹${sub.paidAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(9),
                          fontWeight: FontWeight.w600,
                          color: PaalvandiTheme.deliveredGreen,
                        ),
                      ),
                      SizedBox(height: scaleF(2)),
                      Text(
                        'total amount of product: ₹${totalProductAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(9),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(4)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(4)),
                        decoration: BoxDecoration(
                          color: sub.isDelivered
                              ? (sub.balanceAmount > 0 ? const Color(0xFFC8E6C9) : const Color(0xFFECEFF1))
                              : (sub.isSkipped
                                  ? const Color(0xFFECEFF1)
                                  : const Color(0xFFFFB74D)), // Solid green, grey, or orange
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black, width: 1.2),
                        ),
                        child: Text(
                          sub.isDelivered
                              ? (sub.balanceAmount > 0
                                  ? 'Collected Cash: ₹${sub.balanceAmount.toStringAsFixed(0)}'
                                  : 'No Balance Due')
                              : (sub.isSkipped
                                  ? 'Collected Cash: ₹0'
                                  : 'need to collect this much: ₹${sub.balanceAmount.toStringAsFixed(0)}'),
                          style: GoogleFonts.montserrat(
                            fontSize: fs(9),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                }(),
              ),
            ],
          ),
          SizedBox(height: scaleF(8)),

          // Timing, product qty, bottles, & delivery/skip time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Product badges
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: scaleF(6), vertical: scaleF(2)),
                    decoration: BoxDecoration(
                      color: PaalvandiTheme.primaryBlue, // Solid blue
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                    child: Text(
                      sub.quantity,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(9),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: scaleF(6)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: scaleF(6), vertical: scaleF(2)),
                    decoration: BoxDecoration(
                      color: Colors.amber, // Solid amber/yellow
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                    child: Text(
                      sub.bottleType,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(9),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              // Time stamp display
              if (sub.isDelivered || sub.isSkipped)
                Row(
                  children: [
                    Icon(
                      sub.isDelivered ? Icons.check_circle_outlined : Icons.info_outline,
                      size: scaleF(12),
                      color: sub.isDelivered ? PaalvandiTheme.deliveredGreen : PaalvandiTheme.statusError,
                    ),
                    SizedBox(width: scaleF(4)),
                    Text(
                      '${sub.isDelivered ? "Delivered" : "Skipped"} at ${_getMockTimeForSub(sub)}',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(9),
                        fontWeight: FontWeight.bold,
                        color: sub.isDelivered ? PaalvandiTheme.deliveredGreen : PaalvandiTheme.statusError,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Pending Delivery',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(9),
                    fontWeight: FontWeight.bold,
                    color: PaalvandiTheme.statusPending,
                  ),
                ),
            ],
          ),

          // Skip Reason or Bottle Collection details
          if (sub.isSkipped && sub.skipReason != null) ...[
            SizedBox(height: scaleF(6)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(scaleF(6)),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black, width: 0.5),
              ),
              child: Text(
                'Skip Reason: ${sub.skipReason}',
                style: GoogleFonts.montserrat(
                  fontSize: fs(9),
                  fontWeight: FontWeight.bold,
                  color: PaalvandiTheme.statusError,
                ),
              ),
            ),
          ] else if (sub.isDelivered && sub.pendingBottles > 0) ...[
            SizedBox(height: scaleF(6)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(scaleF(6)),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black, width: 0.5),
              ),
              child: Text(
                'Collected: ${sub.bottlesCollected} of ${sub.pendingBottles} bottles',
                style: GoogleFonts.montserrat(
                  fontSize: fs(9),
                  fontWeight: FontWeight.bold,
                  color: PaalvandiTheme.deliveredGreen,
                ),
              ),
            ),
          ] else if (!sub.isDelivered && !sub.isSkipped && sub.pendingBottles > 0) ...[
            SizedBox(height: scaleF(6)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(scaleF(6)),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black, width: 0.5),
              ),
              child: Text(
                'Pending empty bottles: ${sub.pendingBottles}',
                style: GoogleFonts.montserrat(
                  fontSize: fs(9),
                  fontWeight: FontWeight.bold,
                  color: PaalvandiTheme.statusWarning,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
