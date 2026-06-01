import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../payment/views/order_tracking_view.dart';
import '../../payment/views/refund_status_view.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/order_history_model.dart';
import '../viewmodels/cart_scope.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/order_delivery_otp_compact.dart';
import '../widgets/order_products_summary.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: CustomersLoginThemeView.primaryBlue,
        ),
        title: Text(
          'Order History',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: cart,
        builder: (context, _) {
          final orders = cart.allOrderHistory;
          if (orders.isEmpty) {
            return Center(
              child: Text(
                'No orders yet',
                style: CustomersLoginThemeView.subtitleStyle,
              ),
            );
          }
          return ListView.separated(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _OrderHistoryCard(
                order: orders[index],
                cart: cart,
              );
            },
          );
        },
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final OrderHistoryEntry order;
  final CartViewModel cart;

  const _OrderHistoryCard({
    required this.order,
    required this.cart,
  });

  void _openTracking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScope(
          store: cart,
          child: OrderTrackingView(orderId: order.id),
        ),
      ),
    );
  }

  void _openRefundStatus(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RefundStatusView(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy · hh:mm a').format(order.orderedAt);
    final isCancelled = order.isCancelled ||
        order.summaryLines.contains('Order cancelled');
    final products = order.displayProducts;
    final footers = order.displayFooters;
    final tracked = cart.trackedOrderFor(order.id);
    final otp = tracked?.deliveryOtp;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: ${order.id}',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    if (isCancelled && order.cancellationId != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Cancellation ID: ${order.cancellationId}',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: CustomersLoginThemeView.sectionHeadingRed,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '₹${order.totalRupees}',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.priceAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            dateStr,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: CustomersLoginThemeView.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          OrderProductsSummary(
            products: products,
            footerLines: const [],
            showInlineThumbnails: true,
            thumbnailSize: 52,
            statusLine: isCancelled ? 'Order cancelled' : null,
            statusIsError: true,
          ),
          if (footers.isNotEmpty || (!isCancelled && otp != null)) ...[
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.12),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: footers
                        .map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              line,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: CustomersLoginThemeView.quantityAccent,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (!isCancelled && otp != null)
                  OrderDeliveryOtpCompact(otp: otp),
              ],
            ),
          ],
          if (isCancelled) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: () => _openRefundStatus(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CustomersLoginThemeView.primaryBlue,
                  side: const BorderSide(
                    color: CustomersLoginThemeView.primaryBlue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Refund Status',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () => _openTracking(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomersLoginThemeView.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Track Order',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
