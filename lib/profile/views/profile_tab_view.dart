import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cart/viewmodels/cart_scope.dart';
import '../../theme/customers_login_themeview.dart';

class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final wallet = cart.walletStats;
    final pending = wallet.pendingBottles;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: CustomersLoginThemeView.titleStyle.copyWith(fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: AnimatedBuilder(
        animation: cart,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                'Bottle Wallet',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.sectionHeadingRed,
                ),
              ),
              const SizedBox(height: 12),
              _walletStatCard(
                'Delivered Bottles',
                '${wallet.deliveredBottles}',
              ),
              const SizedBox(height: 10),
              _walletStatCard(
                'Returned Bottles',
                '${wallet.returnedBottles}',
              ),
              const SizedBox(height: 10),
              _walletStatCard(
                'Pending Bottles',
                '$pending',
                highlight: pending > 0,
              ),
              const SizedBox(height: 10),
              _walletStatCard(
                'Refund Balance',
                '₹${wallet.refundBalanceRupees}',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CustomersLoginThemeView.primaryBlue,
                    side: const BorderSide(
                      color: CustomersLoginThemeView.primaryBlue,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: CustomersLoginThemeView.primaryBlue,
                        content: Text(
                          'Bottle history coming soon',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'View Bottle History',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _walletStatCard(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlight
            ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? CustomersLoginThemeView.primaryBlue
              : CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.25),
          width: highlight ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CustomersLoginThemeView.textDark,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: CustomersLoginThemeView.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
