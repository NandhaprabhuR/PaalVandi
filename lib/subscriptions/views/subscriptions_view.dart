import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/subscriptions_viewmodel.dart';
import '../models/subscription_delivery_model.dart';
import 'route_details_view.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/services/haptic_service.dart';

class SubscriptionsView extends StatefulWidget {
  const SubscriptionsView({super.key});

  @override
  State<SubscriptionsView> createState() => _SubscriptionsViewState();
}

class _SubscriptionsViewState extends State<SubscriptionsView> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionsViewModel>().add(const LoadSubscriptions());
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

  @override
  Widget build(BuildContext context) {
    final scaleF =
        (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs =
        (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return BlocBuilder<SubscriptionsViewModel, SubscriptionsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: PaalvandiTheme.bgCream,
            appBar: _buildAppBar(fs),
            body: ListView.builder(
              padding: EdgeInsets.all(hPadding),
              itemCount: 3,
              itemBuilder: (_, __) => Padding(
                padding: EdgeInsets.only(bottom: scaleF(12)),
                child: const SkeletonCard(),
              ),
            ),
          );
        }

        // Calculate metrics
        final totalRoutes = state.routeStatuses.length;
        final completedRoutes = state.routeStatuses.values.where((v) => v == 'Completed').length;
        
        int totalCustomers = 0;
        double totalVolume = 0.0;
        for (final sub in state.subscriptions) {
          if (sub.status == 'Active') {
            totalCustomers++;
            totalVolume += _parseVolume(sub.quantity);
          }
        }

        final progressPercent = totalRoutes > 0 ? (completedRoutes / totalRoutes) : 0.0;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: PaalvandiTheme.bgCream,
            appBar: _buildAppBar(fs),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── TOP SUMMARY CARD ───
                Container(
                  margin: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
                  padding: EdgeInsets.all(scaleF(16)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem('Routes', '$totalRoutes Assign', Icons.alt_route, scaleF, fs),
                          Container(width: 1, height: scaleF(30), color: PaalvandiTheme.dividerColor),
                          _buildStatItem('Volume', '${totalVolume.toStringAsFixed(1)}L Planned', Icons.water_drop_outlined, scaleF, fs),
                          Container(width: 1, height: scaleF(30), color: PaalvandiTheme.dividerColor),
                          _buildStatItem('Customers', '$totalCustomers Active', Icons.people_outline, scaleF, fs),
                        ],
                      ),
                      SizedBox(height: scaleF(16)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Routes Progress',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(10),
                                  fontWeight: FontWeight.bold,
                                  color: PaalvandiTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '$completedRoutes of $totalRoutes Completed',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(10),
                                  fontWeight: FontWeight.w900,
                                  color: PaalvandiTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: scaleF(6)),
                          Stack(
                            children: [
                              Container(
                                height: scaleF(8),
                                decoration: BoxDecoration(
                                  color: PaalvandiTheme.bgLight,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.black, width: 0.5),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progressPercent,
                                child: Container(
                                  height: scaleF(8),
                                  decoration: BoxDecoration(
                                    color: PaalvandiTheme.primaryBlue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

                // Tab Bar View content
                Expanded(
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildRouteList(context, state.morningDeliveries, state.routeStatuses, scaleF, fs, hPadding),
                      _buildRouteList(context, state.eveningDeliveries, state.routeStatuses, scaleF, fs, hPadding),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(Function fs) {
    return AppBar(
      backgroundColor: PaalvandiTheme.bgCream,
      elevation: 0,
      title: Column(
        children: [
          Text(
            "Today's Subscriptions",
            style: GoogleFonts.montserrat(
              fontSize: fs(16),
              fontWeight: FontWeight.w900,
              color: PaalvandiTheme.deliveredGreen,
            ),
          ),
          Text(
            "Recurring milk deliveries assigned to you",
            style: GoogleFonts.montserrat(
              fontSize: fs(10),
              fontWeight: FontWeight.w500,
              color: PaalvandiTheme.textSecondary,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today, color: PaalvandiTheme.textDark),
          tooltip: 'Subscription History',
          onPressed: () {
            HapticService.light();
            context.push('/subscriptions/history');
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Function scaleF, Function fs) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: scaleF(18), color: PaalvandiTheme.primaryBlue),
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
              fontSize: fs(11),
              fontWeight: FontWeight.bold,
              color: PaalvandiTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteList(
    BuildContext context,
    List<SubscriptionDeliveryModel> subs,
    Map<String, String> routeStatuses,
    Function scaleF,
    Function fs,
    double hPadding,
  ) {
    // Group subs by route
    final routeNames = subs.map((s) => s.routeName).toSet().toList();

    if (routeNames.isEmpty) {
      return Center(
        child: Text(
          'No routes assigned',
          style: GoogleFonts.montserrat(
            fontSize: fs(12),
            fontWeight: FontWeight.bold,
            color: PaalvandiTheme.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
      itemCount: routeNames.length,
      separatorBuilder: (_, __) => SizedBox(height: scaleF(12)),
      itemBuilder: (context, index) {
        final routeName = routeNames[index];
        final routeSubs = subs.where((s) => s.routeName == routeName).toList();
        final activeSubs = routeSubs.where((s) => s.status == 'Active').toList();
        
        double routeVolume = 0.0;
        for (final s in activeSubs) {
          routeVolume += _parseVolume(s.quantity);
        }

        final status = routeStatuses[routeName] ?? 'Not Started';

        return _buildRouteCard(context, routeName, routeSubs.length, routeVolume, status, scaleF, fs);
      },
    );
  }

  Widget _buildRouteCard(
    BuildContext context,
    String name,
    int customerCount,
    double volume,
    String status,
    Function scaleF,
    Function fs,
  ) {
    Color buttonColor;
    String buttonText;
    Color textColor = Colors.white;

    if (status == 'Completed') {
      buttonColor = PaalvandiTheme.accentGreen;
      buttonText = 'Completed';
    } else if (status == 'In Progress') {
      buttonColor = PaalvandiTheme.primaryBlue;
      buttonText = 'Resume Route';
    } else {
      buttonColor = PaalvandiTheme.primaryBlue;
      buttonText = 'Start Route';
    }

    return GestureDetector(
      onTap: () {
        HapticService.light();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteDetailsView(routeName: name),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(scaleF(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: PaalvandiTheme.primaryBlue, size: scaleF(20)),
                SizedBox(width: scaleF(8)),
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: PaalvandiTheme.deliveredGreen,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleF(8)),
            Row(
              children: [
                Text(
                  '$customerCount Customers',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(11),
                    fontWeight: FontWeight.w600,
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleF(8)),
                  child: Text('•', style: TextStyle(color: PaalvandiTheme.textMuted, fontSize: fs(12))),
                ),
                Text(
                  '${volume.toStringAsFixed(1)}L Milk Volume',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(11),
                    fontWeight: FontWeight.w600,
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: scaleF(16)),
            GestureDetector(
              onTap: () {
                HapticService.medium();
                if (status == 'Not Started') {
                  context.read<SubscriptionsViewModel>().add(StartRoute(name));
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RouteDetailsView(routeName: name),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    buttonText,
                    style: GoogleFonts.montserrat(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fs(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
