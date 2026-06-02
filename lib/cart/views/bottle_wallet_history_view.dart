import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/widgets/bottle_return_success_dialog.dart';
import '../../core/widgets/paalvandi_confirm_dialog.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/bottle_history_model.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/cart_scope.dart';
import '../widgets/cart_product_thumbnail.dart';
import '../../core/services/haptic_service.dart';

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
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
    final cart = CartScope.of(context);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);

    final totalDepositPaid = delivered * 20;
    final totalDepositRefunded = returned * 20;
    final pendingBottleRefund = pending * 20;

    return Container(
      padding: EdgeInsets.all(scaleF(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bottle Wallet Summary',
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              fontWeight: FontWeight.w800,
              color: CustomersLoginThemeView.textDark,
            ),
          ),
          SizedBox(height: scaleF(12)),
          Row(
            children: [
              Expanded(child: _statItem('Delivered', '$delivered', 'Paid: ₹$totalDepositPaid', scaleF, fs)),
              Container(width: 1, height: scaleF(40), color: Colors.grey.shade300),
              Expanded(child: _statItem('Returned', '$returned', 'Refund: ₹$totalDepositRefunded', scaleF, fs)),
              Container(width: 1, height: scaleF(40), color: Colors.grey.shade300),
              Expanded(child: _statItem('Pending', '$pending', 'Pending: ₹$pendingBottleRefund', scaleF, fs, highlight: pending > 0)),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: scaleF(24)),
          _statRow('Refund Balance Owed', '₹$refundBalance', fs),
          SizedBox(height: scaleF(12)),
          SizedBox(
            height: scaleF(40),
            child: ElevatedButton.icon(
              onPressed: pending == 0
                  ? null
                  : () {
                      final currentPending = pending;
                      HapticService.mediumImpact();
                      cart.simulateDoorstepPickup();
                      HapticService.success();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Row(
                            children: [
                              Text('🚚 ', style: TextStyle(fontSize: 24)),
                              Text('Pickup Scheduled'),
                            ],
                          ),
                          content: Text(
                            'Our agent Ramesh Kumar will collect your $currentPending empty glass bottles at your doorstep. ₹${currentPending * 20} refund has been credited directly to your bottle wallet!',
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                          ),
                          actions: [
                            TextButton(
                              child: Text('Great!', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: CustomersLoginThemeView.primaryBlue)),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      );
                    },
              icon: const Icon(Icons.delivery_dining_outlined, size: 18),
              label: Text(
                'Request Doorstep Pickup',
                style: GoogleFonts.montserrat(
                  fontSize: fs(12),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomersLoginThemeView.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade500,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: pending == 0 ? Colors.transparent : Colors.black, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String val, String sub, double Function(double) scaleF, double Function(double) fs, {bool highlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: fs(11),
            fontWeight: FontWeight.w600,
            color: CustomersLoginThemeView.textGrey,
          ),
        ),
        SizedBox(height: scaleF(2)),
        Text(
          val,
          style: GoogleFonts.montserrat(
            fontSize: fs(16),
            fontWeight: FontWeight.w800,
            color: highlight ? CustomersLoginThemeView.sectionHeadingRed : CustomersLoginThemeView.primaryBlue,
          ),
        ),
        SizedBox(height: scaleF(2)),
        Text(
          sub,
          style: GoogleFonts.montserrat(
            fontSize: fs(9),
            fontWeight: FontWeight.bold,
            color: highlight ? CustomersLoginThemeView.sectionHeadingRed.withOpacity(0.8) : CustomersLoginThemeView.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _statRow(String label, String value, double Function(double) fs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: fs(13),
            fontWeight: FontWeight.bold,
            color: CustomersLoginThemeView.textDark,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: fs(15),
            fontWeight: FontWeight.w900,
            color: CustomersLoginThemeView.priceAccent,
          ),
        ),
      ],
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
    HapticService.success();
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
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Info Column on the left, Image Thumbnail on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      '${entry.quantity} · Wallet ID: ${entry.walletId ?? 'W4T8Y'} · Order ${entry.orderId}',
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
                  ],
                ),
              ),
              const SizedBox(width: 10),
              CartProductThumbnail(size: 72, productName: entry.productName),
            ],
          ),
          
          // Bottom section: Full length Return Bottle button in blue theme
          if (_canReturnBottle || returnRequested) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: returnRequested
                    ? null
                    : () {
                        HapticService.lightImpact();
                        _confirmReturn(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomersLoginThemeView.primaryBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  returnRequested
                      ? 'Return requested'
                      : 'Return Bottle',
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
