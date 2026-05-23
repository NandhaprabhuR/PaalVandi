import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../cart/viewmodels/cart_scope.dart';
import '../../../theme/customers_login_themeview.dart';
import '../../models/home_catalog_data.dart';

class HomeProductCard extends StatelessWidget {
  static const double cardHeight = 178;
  static const double cardRadius = 24;

  final String productName;
  final HomeProductItem item;
  final bool showDepositBadge;
  final bool showRefillBadge;

  const HomeProductCard({
    super.key,
    required this.productName,
    required this.item,
    this.showDepositBadge = true,
    this.showRefillBadge = true,
  });

  static final TextStyle _badgeStyle = GoogleFonts.montserrat(
    fontSize: 8,
    fontWeight: FontWeight.w600,
    color: CustomersLoginThemeView.primaryBlue,
    height: 1.2,
  );

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);

    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        final count = cart.countInCart(productName, item.quantity);

        return SizedBox(
          width: 152,
          height: cardHeight,
          child: Container(
            margin: const EdgeInsets.only(right: 14),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(
                color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: CustomersLoginThemeView.primaryBlue
                                .withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.local_drink_outlined,
                            size: 30,
                            color: CustomersLoginThemeView.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CustomersLoginThemeView.textDark,
                          height: 1.0,
                        ),
                      ),
                      if (showDepositBadge || showRefillBadge) ...[
                        const SizedBox(height: 3),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDepositBadge)
                              Text('♻ Glass Return', style: _badgeStyle),
                            if (showRefillBadge)
                              Text('🥣 Refill', style: _badgeStyle),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              item.quantity,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: CustomersLoginThemeView.quantityAccent,
                                height: 1.0,
                              ),
                            ),
                          ),
                          Text(
                            item.price,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: CustomersLoginThemeView.priceAccent,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: count == 0
                      ? _addOnlyButton(
                          onTap: () => cart.addFromHome(productName, item),
                        )
                      : _quantityStepper(
                          count: count,
                          onAdd: () => cart.addFromHome(productName, item),
                          onRemove: () =>
                              cart.decrementFromHome(productName, item.quantity),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _addOnlyButton({required VoidCallback onTap}) {
    return Material(
      color: CustomersLoginThemeView.primaryBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _quantityStepper({
    required int count,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CustomersLoginThemeView.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepTap(Icons.remove, onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$count',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: CustomersLoginThemeView.primaryBlue,
              ),
            ),
          ),
          _stepTap(Icons.add, onAdd),
        ],
      ),
    );
  }

  Widget _stepTap(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: CustomersLoginThemeView.primaryBlue),
      ),
    );
  }
}
