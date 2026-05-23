import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';

class AddedToCartBar extends StatelessWidget {
  final VoidCallback onViewCart;
  final VoidCallback onDismiss;

  const AddedToCartBar({
    super.key,
    required this.onViewCart,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const ValueKey('added_to_cart_bar'),
      direction: DismissDirection.down,
      onDismissed: (_) => onDismiss(),
      child: Material(
        color: CustomersLoginThemeView.primaryBlue,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Added to cart',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewCart,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'View Cart',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
