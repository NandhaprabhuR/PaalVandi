import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../cart/viewmodels/cart_scope.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';
import '../../cart/models/order_display_models.dart';
import '../../payment/models/tracked_order_model.dart';
import '../../payment/models/payment_model.dart';

class DeliveryPartnerView extends StatefulWidget {
  final String orderId;

  const DeliveryPartnerView({super.key, required this.orderId});

  @override
  State<DeliveryPartnerView> createState() => _DeliveryPartnerViewState();
}

class _DeliveryPartnerViewState extends State<DeliveryPartnerView> {
  bool _isLocalLoading = true;
  late final DateTime _orderTime;
  late Timer _timelineTimer;
  bool _isPacked = false;

  // Mock courier partner details
  static const driverName = 'Ramesh Kumar';
  static const driverPhone = '9361051718';
  static const vehicleNo = 'TN 37 CZ 1234';
  static const supportPhone = '9361051718';

  @override
  void initState() {
    super.initState();
    // Simulate high-fidelity skeleton loading delay of 1 second
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLocalLoading = false;
        });
      }
    });

    // Simulate order placed 4 minutes and 50 seconds ago,
    // so it automatically changes status 10 seconds after screen opens.
    _orderTime = DateTime.now().subtract(const Duration(minutes: 4, seconds: 50));
    
    // Check initial state
    final elapsedSec = DateTime.now().difference(_orderTime).inSeconds;
    _isPacked = elapsedSec >= 300;

    // Check periodically every second to update UI
    _timelineTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final elapsed = DateTime.now().difference(_orderTime).inSeconds;
        if (elapsed >= 300 && !_isPacked) {
          setState(() {
            _isPacked = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timelineTimer.cancel();
    super.dispose();
  }

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    try {
      // Launch phone dialer directly without canLaunchUrl to bypass Android 11+ visibility checks
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to launch phone call: $e');
    }
  }

  TrackedOrder _getOrMockTrackedOrder(CartViewModel? cart) {
    if (cart != null) {
      final order = cart.trackedOrderFor(widget.orderId);
      if (order != null) return order;
    }
    // Fallback mock order details if not found (e.g., PV98302X)
    return TrackedOrder(
      orderId: widget.orderId,
      placedAt: _orderTime,
      totalRupees: 155,
      paymentMethod: PaalvandiPaymentMethod.payAtDelivery,
      productSummaries: const ['Fresh Cow Milk 1L ×2', 'Deposit for glass bottle ₹40'],
      products: const [
        OrderProductDisplay(
          titleLine: 'Fresh Cow Milk 1L ×2',
          detailLine: 'Deposit for glass bottle ₹40',
        ),
      ],
      deliveryOtp: '4820',
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);
    final cartViewModel = CartScope.maybeOf(context);
    final order = _getOrMockTrackedOrder(cartViewModel);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: CustomersLoginThemeView.primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Live Delivery Tracking',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(20),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLocalLoading
          ? _buildSkeletonBody(context, hPadding, scaleF, fs)
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
                    children: [
                      // Delivery Partner profile card (matches theme)
                      Container(
                        padding: EdgeInsets.all(scaleF(16)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: scaleF(52),
                              height: scaleF(52),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.08),
                                border: Border.all(color: CustomersLoginThemeView.primaryBlue, width: 1.5),
                              ),
                              child: const Center(
                                child: Icon(Icons.person, color: CustomersLoginThemeView.primaryBlue, size: 28),
                              ),
                            ),
                            SizedBox(width: scaleF(14)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driverName,
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(15),
                                      fontWeight: FontWeight.w800,
                                      color: CustomersLoginThemeView.textDark,
                                    ),
                                  ),
                                  SizedBox(height: scaleF(2)),
                                  Text(
                                    'Vehicle: $vehicleNo',
                                    style: GoogleFonts.montserrat(
                                      fontSize: fs(12),
                                      fontWeight: FontWeight.bold,
                                      color: CustomersLoginThemeView.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Container(
                                padding: EdgeInsets.all(scaleF(8)),
                                decoration: const BoxDecoration(
                                  color: CustomersLoginThemeView.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.call, color: Colors.white, size: 18),
                              ),
                              onPressed: () => _makeCall(driverPhone),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: scaleF(20)),

                      // Product Details Card (matches theme)
                      Container(
                        padding: EdgeInsets.all(scaleF(16)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Details',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(14),
                                fontWeight: FontWeight.w800,
                                color: CustomersLoginThemeView.textDark,
                              ),
                            ),
                            SizedBox(height: scaleF(12)),
                            ...order.products.map((p) => Padding(
                              padding: EdgeInsets.only(bottom: scaleF(8)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: scaleF(5)),
                                    child: const Icon(Icons.circle, size: 6, color: CustomersLoginThemeView.primaryBlue),
                                  ),
                                  SizedBox(width: scaleF(8)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.titleLine,
                                          style: GoogleFonts.montserrat(
                                            fontSize: fs(13),
                                            fontWeight: FontWeight.bold,
                                            color: CustomersLoginThemeView.textDark,
                                          ),
                                        ),
                                        if (p.detailLine != null)
                                          Text(
                                            p.detailLine!,
                                            style: GoogleFonts.montserrat(
                                              fontSize: fs(11),
                                              color: CustomersLoginThemeView.textGrey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                            const Divider(color: Colors.grey, thickness: 0.5),
                            SizedBox(height: scaleF(4)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payment Status',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(12),
                                    fontWeight: FontWeight.w600,
                                    color: CustomersLoginThemeView.textGrey,
                                  ),
                                ),
                                Text(
                                  order.paymentLabel,
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(12),
                                    fontWeight: FontWeight.bold,
                                    color: CustomersLoginThemeView.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: scaleF(6)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(13),
                                    fontWeight: FontWeight.w800,
                                    color: CustomersLoginThemeView.textDark,
                                  ),
                                ),
                                Text(
                                  '₹${order.totalRupees}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(15),
                                    fontWeight: FontWeight.w900,
                                    color: CustomersLoginThemeView.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: scaleF(24)),

                      Text(
                        'Order Progress - ID: #${widget.orderId}',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(14),
                          fontWeight: FontWeight.bold,
                          color: CustomersLoginThemeView.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(16)),

                      // Custom post-order timeline progress steps (NO emojis, theme matched)
                      _buildTimelineStep(
                        context,
                        title: 'Order Received',
                        desc: 'Your order has been received and confirmed.',
                        timeText: DateFormat('h:mm a').format(_orderTime),
                        isCompleted: true,
                        isLast: false,
                        scaleF: scaleF,
                        fs: fs,
                      ),
                      _buildTimelineStep(
                        context,
                        title: 'Packing in Glass Bottles',
                        desc: 'Fresh milk is packaged in sterilized glass bottles.',
                        timeText: _isPacked 
                            ? DateFormat('h:mm a').format(_orderTime.add(const Duration(minutes: 5)))
                            : 'In progress',
                        isCompleted: _isPacked,
                        isLast: false,
                        scaleF: scaleF,
                        fs: fs,
                      ),
                      _buildTimelineStep(
                        context,
                        title: 'Ready to Deliver',
                        desc: 'Bottles are sealed and loaded onto the delivery vehicle.',
                        timeText: 'Pending',
                        isCompleted: false,
                        isLast: false,
                        scaleF: scaleF,
                        fs: fs,
                      ),
                      _buildTimelineStep(
                        context,
                        title: 'Delivered',
                        desc: 'Delivered to your doorstep.',
                        timeText: 'Expected around ${DateFormat('h:mm a').format(_orderTime.add(const Duration(minutes: 20)))}',
                        isCompleted: false,
                        isLast: true,
                        scaleF: scaleF,
                        fs: fs,
                      ),
                    ],
                  ),
                ),
                
                // Support area (no emojis, theme matched)
                InkWell(
                  onTap: () => _makeCall(supportPhone),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(hPadding, 12, hPadding, 16 + MediaQuery.paddingOf(context).bottom),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.help_outline, color: CustomersLoginThemeView.sectionHeadingRed, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Delivery issues?',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(12),
                                  fontWeight: FontWeight.bold,
                                  color: CustomersLoginThemeView.textDark,
                                ),
                              ),
                              Text(
                                'Contact PaalVandi support: $supportPhone',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(11),
                                  fontWeight: FontWeight.bold,
                                  color: CustomersLoginThemeView.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: CustomersLoginThemeView.textGrey, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required String title,
    required String desc,
    required String timeText,
    required bool isCompleted,
    required bool isLast,
    required double Function(double) scaleF,
    required double Function(double) fs,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: scaleF(26),
                height: scaleF(26),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? CustomersLoginThemeView.primaryBlue : Colors.white,
                  border: Border.all(
                    color: isCompleted ? CustomersLoginThemeView.primaryBlue : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isCompleted ? Icons.check : Icons.circle_outlined,
                    color: isCompleted ? Colors.white : Colors.grey.shade400,
                    size: 14,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? CustomersLoginThemeView.primaryBlue : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: scaleF(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.montserrat(
                            fontSize: fs(13),
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? CustomersLoginThemeView.textDark : CustomersLoginThemeView.textGrey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeText,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(10),
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? CustomersLoginThemeView.primaryBlue : CustomersLoginThemeView.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(11),
                      color: CustomersLoginThemeView.textGrey,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonBody(
    BuildContext context,
    double hPadding,
    double Function(double) scaleF,
    double Function(double) fs,
  ) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
      children: [
        // 1. Driver card skeleton
        Container(
          padding: EdgeInsets.all(scaleF(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
          ),
          child: Row(
            children: [
              ShimmerSkeleton(width: scaleF(52), height: scaleF(52), borderRadius: 26),
              SizedBox(width: scaleF(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerSkeleton(width: scaleF(120), height: scaleF(14), borderRadius: 3),
                    SizedBox(height: scaleF(6)),
                    ShimmerSkeleton(width: scaleF(80), height: scaleF(10), borderRadius: 3),
                  ],
                ),
              ),
              ShimmerSkeleton(width: scaleF(34), height: scaleF(34), borderRadius: 17),
            ],
          ),
        ),
        SizedBox(height: scaleF(20)),

        // 2. Order details skeleton card
        Container(
          padding: EdgeInsets.all(scaleF(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerSkeleton(width: scaleF(100), height: scaleF(14), borderRadius: 3),
              SizedBox(height: scaleF(14)),
              ShimmerSkeleton(width: scaleF(180), height: scaleF(12), borderRadius: 3),
              SizedBox(height: scaleF(6)),
              ShimmerSkeleton(width: scaleF(150), height: scaleF(10), borderRadius: 3),
              SizedBox(height: scaleF(12)),
              const Divider(color: Colors.grey, thickness: 0.2),
              SizedBox(height: scaleF(6)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerSkeleton(width: scaleF(80), height: scaleF(10), borderRadius: 3),
                  ShimmerSkeleton(width: scaleF(60), height: scaleF(10), borderRadius: 3),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: scaleF(24)),

        // 3. Heading skeleton
        Row(
          children: [
            ShimmerSkeleton(width: scaleF(180), height: scaleF(16), borderRadius: 3),
          ],
        ),
        SizedBox(height: scaleF(20)),

        // 4. Timeline rows skeleton
        ...List.generate(4, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: scaleF(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerSkeleton(width: scaleF(26), height: scaleF(26), borderRadius: 13),
                SizedBox(width: scaleF(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerSkeleton(width: scaleF(130), height: scaleF(12), borderRadius: 3),
                          ShimmerSkeleton(width: scaleF(50), height: scaleF(10), borderRadius: 3),
                        ],
                      ),
                      SizedBox(height: scaleF(6)),
                      ShimmerSkeleton(width: scaleF(180), height: scaleF(10), borderRadius: 3),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
