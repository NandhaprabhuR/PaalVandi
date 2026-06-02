import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/customers_login_themeview.dart';
import '../../../core/widgets/responsive_helper.dart';
import '../../models/home_catalog_data.dart';
import 'home_product_card.dart';
import '../bulk_booking_view.dart';

class HomeProductSection extends StatelessWidget {
  final HomeProductSectionData section;
  final int sectionIndex;

  const HomeProductSection({
    super.key,
    required this.section,
    required this.sectionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = ResponsiveHelper.scaleHeight(context, 212).clamp(205.0, 255.0);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(hPadding, scaleF(8), hPadding, scaleF(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                section.heading,
                style: GoogleFonts.montserrat(
                  fontSize: fs(18),
                  fontWeight: FontWeight.bold,
                  color: CustomersLoginThemeView.sectionHeadingRed,
                ),
              ),
              if (section.heading == 'Milk')
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BulkBookingView(
                          initialProduct: 'Fresh Cow Milk',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: scaleF(12), vertical: scaleF(6)),
                    decoration: BoxDecoration(
                      color: CustomersLoginThemeView.primaryBlue,
                      borderRadius: BorderRadius.circular(scaleF(20)),
                      boxShadow: [
                        BoxShadow(
                          color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: fs(12), color: Colors.white),
                        SizedBox(width: scaleF(5)),
                        Text(
                          'Book Bulk',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: hPadding, right: 4),
            itemCount: section.products.length,
            itemBuilder: (context, index) {
              return HomeProductCard(
                productName: section.productName,
                item: section.products[index],
                showDepositBadge: section.showDepositBadge,
                showRefillBadge: section.showRefillBadge,
              );
            },
          ),
        ),
        SizedBox(height: scaleF(8)),
      ],
    );
  }
}
