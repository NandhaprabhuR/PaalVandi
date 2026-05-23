import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/customers_login_themeview.dart';

const String kSubscriptionSupportPhone = '9361051718';

Future<void> showSubscriptionCallDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.support_agent_outlined,
              size: 40,
              color: CustomersLoginThemeView.primaryBlue,
            ),
            const SizedBox(height: 12),
            Text(
              'Need help?',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CustomersLoginThemeView.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Any doubts? You can call us here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CustomersLoginThemeView.textGrey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: CustomersLoginThemeView.primaryBlue.withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CustomersLoginThemeView.primaryBlue.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
              child: Text(
                kSubscriptionSupportPhone,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.primaryBlue,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CustomersLoginThemeView.primaryBlue,
                      side: const BorderSide(
                        color: CustomersLoginThemeView.primaryBlue,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse('tel:$kSubscriptionSupportPhone');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.call, size: 18),
                    label: Text(
                      'Call',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomersLoginThemeView.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
