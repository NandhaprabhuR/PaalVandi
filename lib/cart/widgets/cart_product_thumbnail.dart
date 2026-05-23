import 'package:flutter/material.dart';
import '../../theme/customers_login_themeview.dart';

class CartProductThumbnail extends StatelessWidget {
  final double size;

  const CartProductThumbnail({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.15),
        ),
      ),
      child: Icon(
        Icons.local_drink_outlined,
        size: size * 0.5,
        color: CustomersLoginThemeView.primaryBlue,
      ),
    );
  }
}
