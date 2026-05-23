import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../cart/viewmodels/cart_scope.dart';
import '../../core/widgets/bottle_return_success_dialog.dart';
import '../../core/widgets/paalvandi_confirm_dialog.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/bottle_history_model.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/cart_product_thumbnail.dart';

class BottleWalletHistoryView extends StatelessWidget {
  const BottleWalletHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final wallet = cart.walletStats;
    final history = [
      ...cart.placedBottleHistory,
      ...BottleHistoryData.sampleHistory(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: CustomersLoginThemeView.primaryBlue,
        ),
        title: Text(
          'Bottle History',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _SummaryCard(
            delivered: wallet.deliveredBottles,
            returned: wallet.returnedBottles,
            pending: wallet.pendingBottles,
            refundBalance: wallet.refundBalanceRupees,
          ),
          const SizedBox(height: 16),
          Text(
            'All bottle transactions',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: CustomersLoginThemeView.textDark,
            ),
          ),
          const SizedBox(height: 10),
          ...history.map(
            (entry) => _BottleHistoryTile(cart: cart, entry: entry),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int delivered;
  final int returned;
  final int pending;
  final int refundBalance;

  const _SummaryCard({
    required this.delivered,
    required this.returned,
    required this.pending,
    required this.refundBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          _statRow('Delivered bottles', '$delivered'),
          _statRow('Returned bottles', '$returned'),
          _statRow('Pending bottles', '$pending', highlight: pending > 0),
          _statRow('Refund balance', '₹$refundBalance'),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CustomersLoginThemeView.textDark,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: highlight
                  ? CustomersLoginThemeView.sectionHeadingRed
                  : CustomersLoginThemeView.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottleHistoryTile extends StatelessWidget {
  final CartViewModel cart;
  final BottleHistoryEntry entry;

  const _BottleHistoryTile({required this.cart, required this.entry});

  bool get _canReturnBottle {
    final action = entry.action.toLowerCase();
    return entry.depositRupees > 0 &&
        !action.contains('returned') &&
        !cart.isBottleReturnRequested(entry.orderId);
  }

  Future<void> _confirmReturn(BuildContext context) async {
    if (cart.isBottleReturnRequested(entry.orderId)) return;

    final confirmed = await showPaalvandiConfirmDialog(
      context,
      title: 'Return bottle?',
      message:
          'Return the glass bottle for Order ${entry.orderId}? Deposit refund will be processed after pickup.',
    );
    if (confirmed != true || !context.mounted) return;

    cart.requestBottleReturn(entry.orderId);
    await showBottleReturnSuccessDialog(
      context,
      refundRupees: entry.depositRupees,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy · hh:mm a').format(entry.date);
    final returnRequested = cart.isBottleReturnRequested(entry.orderId);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.productName,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: CustomersLoginThemeView.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.quantity} · Order ${entry.orderId}',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: CustomersLoginThemeView.quantityAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: CustomersLoginThemeView.textGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.action,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CustomersLoginThemeView.primaryBlue,
                  ),
                ),
                Text(
                  'Deposit: ₹${entry.depositRupees}'
                  '${entry.refundRupees != null ? ' · Refund: ₹${entry.refundRupees}' : ''}',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: CustomersLoginThemeView.textGrey,
                  ),
                ),
                if (_canReturnBottle || returnRequested) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton(
                      onPressed: returnRequested
                          ? null
                          : () => _confirmReturn(context),
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
                        returnRequested
                            ? 'Return requested'
                            : 'Return Bottle',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          const CartProductThumbnail(size: 72),
        ],
      ),
    );
  }
}
