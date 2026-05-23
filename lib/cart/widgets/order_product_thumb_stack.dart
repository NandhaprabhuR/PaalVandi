import 'package:flutter/material.dart';
import 'cart_product_thumbnail.dart';

/// Stacked product thumbnails for multi-item orders (right side of cards).
class OrderProductThumbStack extends StatelessWidget {
  final int count;
  final double size;

  const OrderProductThumbStack({
    super.key,
    required this.count,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final shown = count.clamp(1, 4);
    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(shown, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: i < shown - 1 ? 6 : 0),
            child: CartProductThumbnail(size: size),
          );
        }),
      ),
    );
  }
}
