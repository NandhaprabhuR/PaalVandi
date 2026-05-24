import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';

const String kSubscriptionSupportPhone = '9361051718';

Future<void> showSubscriptionCallDialog(BuildContext context) {
  final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
  final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: scaleF(28)),
      child: Container(
        padding: EdgeInsets.fromLTRB(scaleF(20), scaleF(20), scaleF(20), scaleF(16)),
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
            Icon(
              Icons.support_agent_outlined,
              size: scaleF(40),
              color: CustomersLoginThemeView.primaryBlue,
            ),
            SizedBox(height: scaleF(12)),
            Text(
              'Need help?',
              style: GoogleFonts.montserrat(
                fontSize: fs(18),
                fontWeight: FontWeight.w800,
                color: CustomersLoginThemeView.primaryBlue,
              ),
            ),
            SizedBox(height: scaleF(8)),
            Text(
              'Any doubts? You can call us here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: fs(14),
                fontWeight: FontWeight.w500,
                color: CustomersLoginThemeView.textGrey,
                height: 1.4,
              ),
            ),
            SizedBox(height: scaleF(14)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: scaleF(12), vertical: scaleF(4)),
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
              child: Row(
                children: [
                  const SizedBox(width: 32), // spacer to balance the icon button
                  Expanded(
                    child: Text(
                      kSubscriptionSupportPhone,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(21),
                        fontWeight: FontWeight.w800,
                        color: CustomersLoginThemeView.primaryBlue,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy to clipboard',
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(text: kSubscriptionSupportPhone),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Phone number copied!',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: CustomersLoginThemeView.primaryBlue,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.copy_rounded,
                      color: CustomersLoginThemeView.primaryBlue,
                      size: scaleF(20),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: scaleF(20)),
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
                      padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: scaleF(10)),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse('tel:$kSubscriptionSupportPhone');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    icon: Icon(Icons.call, size: scaleF(18)),
                    label: Text(
                      'Call',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomersLoginThemeView.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: scaleF(12)),
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
