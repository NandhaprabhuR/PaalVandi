import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../models/subscription_plan_model.dart';

/// Landscape coupon-style card used on the Subscriptions tab.
class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final VoidCallback onSubscribe;
  final bool isActive;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.onSubscribe,
    this.isActive = false,
  });

  static const double cardRadius = 28;

  @override
  Widget build(BuildContext context) {
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: scaleF(12)),
      decoration: BoxDecoration(
        color: plan.cardTint,
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: Stack(
          children: [
            Positioned(
              right: scaleF(10),
              top: scaleF(12),
              child: Icon(
                plan.icon,
                size: scaleF(76).clamp(60.0, 90.0),
                color: CustomersLoginThemeView.primaryBlue.withValues(
                  alpha: 0.14,
                ),
              ),
            ),
            if (isActive)
              Positioned(
                right: scaleF(16),
                top: scaleF(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Active',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(10),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(scaleF(16), scaleF(16), scaleF(16), scaleF(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min, // shrink-wrap contents dynamically!
                children: [
                  Text(
                    plan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(17),
                      fontWeight: FontWeight.w800,
                      color: CustomersLoginThemeView.sectionHeadingRed,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: scaleF(6)),
                  Text(
                    plan.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(12),
                      fontWeight: FontWeight.w500,
                      color: CustomersLoginThemeView.textDark,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: scaleF(6)),
                  Text(
                    'You can cancel anytime',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(11),
                      fontWeight: FontWeight.w700,
                      color: CustomersLoginThemeView.sectionHeadingRed,
                    ),
                  ),
                  SizedBox(height: scaleF(8)),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: plan.features.take(2).map((f) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          f,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: fs(10),
                            fontWeight: FontWeight.w600,
                            color: CustomersLoginThemeView.textDark,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: scaleF(14)), // Small spacing directly above the button
                  SizedBox(
                    width: double.infinity,
                    height: scaleF(36).clamp(32.0, 42.0),
                    child: ElevatedButton(
                      onPressed: onSubscribe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            CustomersLoginThemeView.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Subscribe',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(13),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
