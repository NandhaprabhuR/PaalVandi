import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../cart/viewmodels/cart_scope.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';

class PaymentHistoryView extends StatelessWidget {
  const PaymentHistoryView({super.key});

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return const Color(0xFFE8F5E9);
      case 'pending':
        return const Color(0xFFFFF3E0);
      case 'failed':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFE65100);
      case 'failed':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        final history = cart.paymentHistory;

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
              'Payment History',
              style: CustomersLoginThemeView.brandTitleStyle.copyWith(
                fontSize: fs(20),
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
          ),
          body: history.isEmpty
              ? Center(
                  child: Text(
                    'No transaction history yet',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.w600,
                      color: CustomersLoginThemeView.textGrey,
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final tx = history[index];
                    final dateStr = DateFormat('dd MMM yyyy · hh:mm a').format(tx.date);

                    return Container(
                      margin: EdgeInsets.only(bottom: scaleF(14)),
                      padding: EdgeInsets.all(scaleF(16)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFD),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${tx.amount.toStringAsFixed(2)}',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(18),
                                  fontWeight: FontWeight.w900,
                                  color: CustomersLoginThemeView.textDark,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(tx.status),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  tx.status.toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(9),
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusTextColor(tx.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: scaleF(10)),
                          _txDetailRow('Date & Time', dateStr, fs),
                          SizedBox(height: scaleF(4)),
                          _txDetailRow('Method', tx.method, fs),
                          SizedBox(height: scaleF(4)),
                          _txDetailRow('Transaction ID', tx.transactionId, fs, isCode: true),
                          SizedBox(height: scaleF(4)),
                          _txDetailRow('Reference No', tx.referenceNumber, fs, isCode: true),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _txDetailRow(String label, String value, double Function(double) fs, {bool isCode = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: fs(11),
            fontWeight: FontWeight.w600,
            color: CustomersLoginThemeView.textGrey,
          ),
        ),
        Text(
          value,
          style: isCode
              ? TextStyle(
                  fontSize: fs(11),
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.primaryBlue,
                  fontFamily: 'Courier',
                )
              : GoogleFonts.montserrat(
                  fontSize: fs(11),
                  fontWeight: FontWeight.w600,
                  color: CustomersLoginThemeView.textDark,
                ),
        ),
      ],
    );
  }
}
