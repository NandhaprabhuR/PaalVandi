import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../cart/viewmodels/cart_scope.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';
import '../../cart/models/order_display_models.dart';
import '../../core/widgets/paalvandi_confirm_dialog.dart';
import '../../cart/widgets/order_delivery_otp_compact.dart';
import '../../cart/widgets/order_products_summary.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/tracked_order_model.dart';

class OrderTrackingView extends StatefulWidget {
  final String orderId;

  const OrderTrackingView({super.key, required this.orderId});

  @override
  State<OrderTrackingView> createState() => _OrderTrackingViewState();
}

class _OrderTrackingViewState extends State<OrderTrackingView> {
  static const _steps = [
    'Order placed',
    'Preparing fresh dairy',
    'Out for delivery',
    'Delivered',
  ];

  int _activeStep = 1;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final cart = CartScope.of(context);
      final order = cart.trackedOrderFor(widget.orderId);
      if (order?.isCancelled == true) return;
      setState(() => _activeStep = 2);
    });
  }

  Future<void> _confirmCancel(CartViewModel cart, TrackedOrder order) async {
    final confirmed = await showPaalvandiConfirmDialog(
      context,
      title: 'Cancel order?',
      message:
          'Are you sure you want to cancel Order ${order.orderId}? This cannot be undone.',
    );
    if (confirmed != true || !mounted) return;

    cart.cancelOrder(order.orderId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CustomersLoginThemeView.primaryBlue,
        content: Text(
          'Order ${order.orderId} cancelled',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final order = cart.trackedOrderFor(widget.orderId);

    if (order == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(context),
        body: Center(
          child: Text(
            'Order not found',
            style: CustomersLoginThemeView.subtitleStyle,
          ),
        ),
      );
    }

    final dateStr = DateFormat('dd MMM yyyy · hh:mm a').format(order.placedAt);
    final cancelled = order.isCancelled;
    final products = order.products.isNotEmpty
        ? order.products
        : order.productSummaries
            .map((line) => OrderProductDisplay(titleLine: line))
            .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: CustomersLoginThemeView.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ${order.orderId}',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: CustomersLoginThemeView.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: CustomersLoginThemeView.textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  order.paymentLabel,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CustomersLoginThemeView.quantityAccent,
                  ),
                ),
                if (cancelled) ...[
                  const SizedBox(height: 8),
                  Text(
                    'This order was cancelled',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CustomersLoginThemeView.sectionHeadingRed,
                    ),
                  ),
                ],
                const Divider(height: 20),
                OrderProductsSummary(
                  products: products,
                  showInlineThumbnails: true,
                  thumbnailSize: 52,
                ),
                if (!cancelled) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Delivery ₹15',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: CustomersLoginThemeView.quantityAccent,
                          ),
                        ),
                      ),
                      OrderDeliveryOtpCompact(otp: order.deliveryOtp),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    Text(
                      '₹${order.totalRupees}',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: CustomersLoginThemeView.priceAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Delivery status',
            style: CustomersLoginThemeView.sectionHeadingStyle.copyWith(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (cancelled)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CustomersLoginThemeView.sectionHeadingRed
                    .withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CustomersLoginThemeView.sectionHeadingRed
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Order cancelled — delivery stopped',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CustomersLoginThemeView.sectionHeadingRed,
                ),
              ),
            )
          else
            ...List.generate(_steps.length, (i) => _stepTile(i, _activeStep)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: CustomersLoginThemeView.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(
                  Icons.local_shipping_outlined,
                  'Estimated delivery',
                  cancelled ? 'Not applicable' : 'Within 20 minutes',
                ),
                const SizedBox(height: 10),
                _infoRow(
                  Icons.schedule_outlined,
                  'Delivery hours',
                  'Morning 5:00 AM to Night 9:00 PM',
                ),
              ],
            ),
          ),
          if (order.canCancel) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () => _confirmCancel(cart, order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CustomersLoginThemeView.sectionHeadingRed,
                  side: BorderSide(
                    color: CustomersLoginThemeView.sectionHeadingRed
                        .withValues(alpha: 0.8),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel Order',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomersLoginThemeView.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Back',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: CustomersLoginThemeView.primaryBlue,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Track Order',
        style: CustomersLoginThemeView.brandTitleStyle.copyWith(
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _stepTile(int index, int active) {
    final done = index <= active;
    final isCurrent = index == active;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: done
                  ? CustomersLoginThemeView.primaryBlue
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: CustomersLoginThemeView.primaryBlue,
                width: 1.5,
              ),
            ),
            child: done
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _steps[index],
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: done
                    ? CustomersLoginThemeView.primaryBlue
                    : CustomersLoginThemeView.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: CustomersLoginThemeView.primaryBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: CustomersLoginThemeView.textGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

