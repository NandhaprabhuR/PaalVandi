import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/bottles_viewmodel.dart';
import '../models/bottle_collection_model.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/services/haptic_service.dart';

class BottlesView extends StatefulWidget {
  const BottlesView({super.key});

  @override
  State<BottlesView> createState() => _BottlesViewState();
}

class _BottlesViewState extends State<BottlesView> {
  @override
  void initState() {
    super.initState();
    context.read<BottlesViewModel>().add(const LoadBottleCollections());
  }

  @override
  Widget build(BuildContext context) {
    final scaleF =
        (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs =
        (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: PaalvandiTheme.bgCream,
      appBar: AppBar(
        backgroundColor: PaalvandiTheme.bgCream,
        elevation: 0,
        title: Text(
          'Bottle Returns',
          style: GoogleFonts.montserrat(
            fontSize: fs(18),
            fontWeight: FontWeight.bold,
            color: PaalvandiTheme.textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: PaalvandiTheme.primaryBlue, size: scaleF(24)),
            onPressed: () {
              HapticService.light();
              context.push('/bottles/history');
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Tab Bar
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
                      Tab(text: 'Pending Returns'),
                      Tab(text: 'Collected Bottles'),
                    ],
                  ),
                  Container(
                    height: 1.0,
                    color: PaalvandiTheme.cardBorderLight,
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<BottlesViewModel, BottlesState>(
        listener: (context, state) {
          if (state.collectedId != null) {
            HapticService.heavy();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Bottles collected successfully!',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: PaalvandiTheme.statusSuccess,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return ListView.builder(
              padding: EdgeInsets.all(hPadding),
              itemCount: 3,
              itemBuilder: (_, __) => Padding(
                padding: EdgeInsets.only(bottom: scaleF(12)),
                child: const SkeletonCard(),
              ),
            );
          }

          final pendingCollections = state.collections.where((c) => !c.isCollected).toList();
          final collectedCollections = state.collections.where((c) => c.isCollected).toList();

          return TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildList(context, pendingCollections, scaleF, fs, hPadding, false),
              _buildList(context, collectedCollections, scaleF, fs, hPadding, true),
            ],
          );
        },
      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<BottleCollectionModel> items, Function scaleF, Function fs, double hPadding, bool isCollectedTab) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/noitemincart.json',
              height: scaleF(120),
            ),
            SizedBox(height: scaleF(16)),
            Text(
              isCollectedTab ? 'No collected bottles' : 'No pending collections today',
              style: GoogleFonts.montserrat(
                fontSize: fs(14),
                fontWeight: FontWeight.bold,
                color: PaalvandiTheme.textDark,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: scaleF(12)),
      itemBuilder: (context, index) {
        return _buildBottleCard(context, items[index], scaleF, fs);
      },
    );
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $period';
  }

  Widget _buildBottleCard(
    BuildContext context,
    BottleCollectionModel col,
    Function scaleF,
    Function fs,
  ) {
    final isDone = col.isCollected;
    final cardColor = isDone
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFE3F2FD);

    return Container(
      padding: EdgeInsets.all(scaleF(16)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Customer Name & Status
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
                padding: EdgeInsets.symmetric(
                  horizontal: scaleF(8),
                  vertical: scaleF(4),
                ),
                decoration: PaalvandiTheme.statusBadgeDecoration(
                  isDone ? PaalvandiTheme.statusSuccess : PaalvandiTheme.primaryBlue,
                ),
                child: Text(
                  isDone ? 'Collected' : 'Pending Return',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(9),
                    fontWeight: FontWeight.bold,
                    color: isDone ? PaalvandiTheme.statusSuccess : PaalvandiTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scaleF(4)),
          Text(
            'Phone: +91 ${col.phone}',
            style: GoogleFonts.montserrat(
              fontSize: fs(11),
              fontWeight: FontWeight.w500,
              color: PaalvandiTheme.textSecondary,
            ),
          ),
          if (col.requestDate != null) ...[
            SizedBox(height: scaleF(4)),
            Text(
              'Requested On: ${_formatDateTime(col.requestDate)}',
              style: GoogleFonts.montserrat(
                fontSize: fs(11),
                fontWeight: FontWeight.w600,
                color: PaalvandiTheme.primaryBlue,
              ),
            ),
          ],
          if (isDone && col.collectionDate != null) ...[
            SizedBox(height: scaleF(4)),
            Text(
              'Collected On: ${_formatDateTime(col.collectionDate)}',
              style: GoogleFonts.montserrat(
                fontSize: fs(11),
                fontWeight: FontWeight.w600,
                color: PaalvandiTheme.statusSuccess,
              ),
            ),
          ],
          SizedBox(height: scaleF(12)),

          // Address
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

          // Stats: Bottle count & deposit refund value
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
                      'PENDING BOTTLES',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(9),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: scaleF(4)),
                    Row(
                      children: [
                        Icon(
                          Icons.recycling_outlined,
                          size: scaleF(18),
                          color: PaalvandiTheme.primaryBlue,
                        ),
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
                        'DEPOSIT VALUE',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(9),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: scaleF(4)),
                      Row(
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            size: scaleF(16),
                            color: PaalvandiTheme.accentGreen,
                          ),
                          Expanded(
                            child: Text(
                              '₹${col.depositValue.toStringAsFixed(0)} Refundable',
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

          if (!isDone) ...[
            SizedBox(height: scaleF(16)),
            Divider(color: PaalvandiTheme.dividerColor, height: 1),
            SizedBox(height: scaleF(12)),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    'Call Customer',
                    Icons.phone_outlined,
                    PaalvandiTheme.accentGreen,
                    () async {
                      HapticService.light();
                      final uri = Uri.parse('tel:${col.phone}');
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    scaleF,
                    fs,
                  ),
                ),
                SizedBox(width: scaleF(8)),
                Expanded(
                  child: _actionButton(
                    'Navigate',
                    Icons.navigation_outlined,
                    PaalvandiTheme.primaryBlue,
                    () {
                      HapticService.light();
                      final encoded = Uri.encodeComponent(col.address);
                      launchUrl(
                        Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    scaleF,
                    fs,
                  ),
                ),
                SizedBox(width: scaleF(8)),
                Expanded(
                  child: _actionButton(
                    'Collect Bottles',
                    Icons.check_circle_outline,
                    PaalvandiTheme.statusSuccess,
                    () {
                      HapticService.medium();
                      _showCollectConfirmationDialog(context, col, scaleF, fs);
                    },
                    scaleF,
                    fs,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    Function scaleF,
    Function fs,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: scaleF(10)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: scaleF(18)),
            SizedBox(height: scaleF(4)),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: fs(9),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCollectConfirmationDialog(BuildContext context, BottleCollectionModel col, Function scaleF, Function fs) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Confirm Collection',
            style: GoogleFonts.montserrat(
              fontSize: fs(16),
              fontWeight: FontWeight.bold,
              color: PaalvandiTheme.textDark,
            ),
          ),
          content: Text(
            'Are you sure you want to mark these bottles as collected and refund the deposit amount paid?',
            style: GoogleFonts.montserrat(
              fontSize: fs(12),
              color: PaalvandiTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticService.light();
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                HapticService.medium();
                Navigator.of(ctx).pop();
                context.read<BottlesViewModel>().add(MarkBottleCollected(col.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PaalvandiTheme.statusSuccess,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Collect',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
