import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../cart/models/order_display_models.dart';
import '../../cart/models/order_history_model.dart';
import '../../cart/widgets/order_products_summary.dart';
import '../../theme/customers_login_themeview.dart';

class RefundStatusView extends StatelessWidget {
  final OrderHistoryEntry order;

  const RefundStatusView({super.key, required this.order});

  List<OrderProductDisplay> get _products => order.products.isNotEmpty
      ? order.products
      : productsFromLegacySummary(order.summaryLines);

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('dd MMM yyyy · hh:mm a').format(order.orderedAt);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: CustomersLoginThemeView.primaryBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Refund Status',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
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
                  'Order ${order.id}',
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
                const SizedBox(height: 12),
                OrderProductsSummary(
                  products: _products,
                  footerLines: order.displayFooters,
                  showInlineThumbnails: true,
                  thumbnailSize: 52,
                ),
                const SizedBox(height: 8),
                Text(
                  'Refund amount: ₹${order.totalRupees}',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: CustomersLoginThemeView.priceAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_outlined,
                      color: CustomersLoginThemeView.primaryBlue,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Refund in progress',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: CustomersLoginThemeView.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your order was cancelled. The refund of ₹${order.totalRupees} will be transferred to your bank account within 3 hours.',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: CustomersLoginThemeView.textGrey,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You will receive a confirmation once the transfer is complete.',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CustomersLoginThemeView.quantityAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
