import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';

Future<void> showBottleReturnSuccessDialog(
  BuildContext context, {
  required int refundRupees,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: CustomersLoginThemeView.primaryBlue,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 36,
                color: CustomersLoginThemeView.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Processing return',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CustomersLoginThemeView.primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Our team will contact you soon. Bottle deposit of ₹$refundRupees will be refunded if the bottle is not broken or damaged.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: CustomersLoginThemeView.textGrey,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomersLoginThemeView.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'OK',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
