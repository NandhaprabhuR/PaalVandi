import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';

/// Compact OTP shown beside delivery info, above action buttons.
class OrderDeliveryOtpCompact extends StatelessWidget {
  final String otp;

  const OrderDeliveryOtpCompact({super.key, required this.otp});

  @override
  Widget build(BuildContext context) {
    final digits = otp.padLeft(4, '0').split('');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Delivery OTP',
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: CustomersLoginThemeView.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: digits
              .map(
                (d) => Container(
                  width: 28,
                  height: 32,
                  margin: const EdgeInsets.only(left: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: CustomersLoginThemeView.primaryBlue,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    d,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: CustomersLoginThemeView.primaryBlue,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
