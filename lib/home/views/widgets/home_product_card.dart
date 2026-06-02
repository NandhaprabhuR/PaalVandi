import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../cart/viewmodels/cart_scope.dart';
import '../../../theme/customers_login_themeview.dart';
import '../../../core/widgets/responsive_helper.dart';
import '../../models/home_catalog_data.dart';
import '../product_details_view.dart';
import '../../../core/services/haptic_service.dart';

class HomeProductCard extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final width = ResponsiveHelper.scaleWidth(context, 152).clamp(135.0, 180.0);
    // Increase card height slightly to provide plenty of vertical breathing room
    final height = ResponsiveHelper.scaleHeight(context, 195).clamp(180.0, 240.0);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);

    final TextStyle badgeStyle = GoogleFonts.montserrat(
      fontSize: fs(8),
      fontWeight: FontWeight.w600,
      color: CustomersLoginThemeView.primaryBlue,
      height: 1.2,
    );

    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        final count = cart.countInCart(productName, item.quantity);

        return SizedBox(
          width: width,
          height: height,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => CartScope(
                    store: cart,
                    child: ProductDetailsView(
                      productName: productName,
                      initialItem: item,
                    ),
                  ),
                  transitionDuration: const Duration(milliseconds: 350),
                  reverseTransitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    final slideIn = Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.fastOutSlowIn,
                        reverseCurve: Curves.fastOutSlowIn,
                      ),
                    );

                    final slideOut = Tween<Offset>(
                      begin: Offset.zero,
                      end: const Offset(-0.3, 0.0),
                    ).animate(
                      CurvedAnimation(
                        parent: secondaryAnimation,
                        curve: Curves.fastOutSlowIn,
                        reverseCurve: Curves.fastOutSlowIn,
                      ),
                    );

                    return SlideTransition(
                      position: slideIn,
                      child: SlideTransition(
                        position: slideOut,
                        child: child,
                      ),
                    );
                  },
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: scaleF(14).clamp(10.0, 18.0)),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _getCardBgColor(productName),
                borderRadius: BorderRadius.circular(cardRadius),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Padding(
                    // Set bottom padding to scaleF(12) and shift the row up using a SizedBox at the bottom of the Column
                    padding: EdgeInsets.fromLTRB(scaleF(10), scaleF(8), scaleF(10), scaleF(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: scaleF(52).clamp(40.0, 60.0),
                            height: scaleF(52).clamp(40.0, 60.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              'assets/allbottles.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: scaleF(4)),
                        Text(
                          productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            fontWeight: FontWeight.w700,
                            color: CustomersLoginThemeView.textDark,
                            height: 1.0,
                          ),
                        ),
                        if (showDepositBadge || showRefillBadge) ...[
                          SizedBox(height: scaleF(3)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showDepositBadge)
                                Text('♻ Deposit Bottle Available', style: badgeStyle),
                              if (showRefillBadge)
                                Text('🥣 Refill Available', style: badgeStyle),
                            ],
                          ),
                        ],
                        const Spacer(),
                        // Quantity and Price row (horizontal gap maintained, but shifted up above the button)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.quantity,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: fs(11),
                                fontWeight: FontWeight.w700,
                                color: CustomersLoginThemeView.quantityAccent,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              item.price,
                              style: GoogleFonts.montserrat(
                                fontSize: fs(13),
                                fontWeight: FontWeight.w800,
                                color: CustomersLoginThemeView.priceAccent,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: scaleF(4)),
                        Row(
                          children: [
                            Text(
                              '⭐ ${item.rating.toStringAsFixed(1)}',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(9),
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.totalOrders,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(8),
                                  fontWeight: FontWeight.w600,
                                  color: CustomersLoginThemeView.textGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Height of 42 leaves exactly enough room for the positioned button/stepper
                        SizedBox(height: scaleF(42)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: scaleF(8),
                    right: scaleF(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.stockStatus == 'Out of Stock'
                            ? const Color(0xFFD32F2F)
                            : (item.stockStatus == 'Low Stock'
                                ? const Color(0xFFF57C00)
                                : const Color(0xFF388E3C)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        item.stockStatus,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(7),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: scaleF(8),
                    bottom: scaleF(8),
                    child: item.stockStatus == 'Out of Stock'
                        ? Container(
                            padding: EdgeInsets.symmetric(horizontal: scaleF(10), vertical: scaleF(6)),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade400, width: 1),
                            ),
                            child: Text(
                              'Sold Out',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(9),
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                        : count == 0
                            ? _addOnlyButton(
                                context,
                                scaleF,
                                onTap: () => cart.addFromHome(productName, item),
                              )
                            : _quantityStepper(
                                context,
                                count: count,
                                fs: fs,
                                scaleF: scaleF,
                                onAdd: () => cart.addFromHome(productName, item),
                                onRemove: () =>
                                    cart.decrementFromHome(productName, item.quantity),
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _addOnlyButton(BuildContext context, double Function(double) scaleF, {required VoidCallback onTap}) {
    return Material(
      color: CustomersLoginThemeView.primaryBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticService.mediumImpact();
          onTap();
        },
        child: Padding(
          padding: EdgeInsets.all(scaleF(8).clamp(6.0, 10.0)),
          child: Icon(Icons.add, color: Colors.white, size: scaleF(20).clamp(16.0, 24.0)),
        ),
      ),
    );
  }

  Widget _quantityStepper(
    BuildContext context, {
    required int count,
    required double Function(double) fs,
    required double Function(double) scaleF,
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
          _stepTap(context, Icons.remove, scaleF, onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$count',
              style: GoogleFonts.montserrat(
                fontSize: fs(12),
                fontWeight: FontWeight.w800,
                color: CustomersLoginThemeView.primaryBlue,
              ),
            ),
          ),
          _stepTap(context, Icons.add, scaleF, onAdd),
        ],
      ),
    );
  }

  Widget _stepTap(BuildContext context, IconData icon, double Function(double) scaleF, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: EdgeInsets.all(scaleF(6).clamp(4.0, 8.0)),
        child: Icon(icon, size: scaleF(16).clamp(12.0, 20.0), color: CustomersLoginThemeView.primaryBlue),
      ),
    );
  }

  Color _getCardBgColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('milk') && !lowerName.contains('butter')) {
      return const Color(0xFFEEF5FF); // Mild Pastel Blue
    } else if (lowerName.contains('curd')) {
      return const Color(0xFFE8F6EC); // Mild Pastel Green
    } else if (lowerName.contains('butter') || lowerName.contains('moor')) {
      return const Color(0xFFFFF2E6); // Mild Pastel Peach/Cream
    }
    return Colors.white;
  }
}
