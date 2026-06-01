import 'package:flutter/material.dart';
import '../../theme/customers_login_themeview.dart';

class CartProductThumbnail extends StatelessWidget {
  final double size;
  final String? productName;

  const CartProductThumbnail({super.key, this.size = 64, this.productName});

  @override
  Widget build(BuildContext context) {
    String imgPath = 'assets/allbottles.png';
    if (productName != null) {
      final nameLower = productName!.toLowerCase();
      if (nameLower.contains('curd')) {
        imgPath = 'assets/100mlbottle.png';
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.15),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Image.asset(
        imgPath,
        fit: BoxFit.contain,
      ),
    );
  }
}
