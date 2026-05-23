import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/customers_login_themeview.dart';
import '../../models/home_catalog_data.dart';
import 'home_product_card.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            section.heading,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CustomersLoginThemeView.sectionHeadingRed,
            ),
          ),
        ),
        SizedBox(
          height: HomeProductCard.cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 4),
            itemCount: section.products.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 350 + (sectionIndex * 80) + (index * 40)),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: HomeProductCard(
                  productName: section.productName,
                  item: section.products[index],
                  showDepositBadge: section.showDepositBadge,
                  showRefillBadge: section.showRefillBadge,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
