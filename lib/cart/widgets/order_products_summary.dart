import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/order_display_models.dart';
import 'cart_product_thumbnail.dart';

/// Product list with optional inline thumbnail per row.
class OrderProductsSummary extends StatelessWidget {
  final List<OrderProductDisplay> products;
  final List<String> footerLines;
  final String? statusLine;
  final bool statusIsError;
  final bool showInlineThumbnails;
  final double thumbnailSize;

  const OrderProductsSummary({
    super.key,
    required this.products,
    this.footerLines = const [],
    this.statusLine,
    this.statusIsError = false,
    this.showInlineThumbnails = false,
    this.thumbnailSize = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < products.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.12),
            ),
            const SizedBox(height: 8),
          ],
          _productRow(products[i]),
        ],
        if (footerLines.isNotEmpty) ...[
          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 6),
          ...footerLines.map(_footerLine),
        ],
        if (statusLine != null) ...[
          const SizedBox(height: 6),
          Text(
            statusLine!,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: statusIsError
                  ? CustomersLoginThemeView.sectionHeadingRed
                  : CustomersLoginThemeView.quantityAccent,
            ),
          ),
        ],
      ],
    );
  }

  Widget _productRow(OrderProductDisplay product) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.titleLine,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: CustomersLoginThemeView.textDark,
          ),
        ),
        if (product.detailLine != null) ...[
          const SizedBox(height: 2),
          Text(
            product.detailLine!,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: CustomersLoginThemeView.quantityAccent,
            ),
          ),
        ],
      ],
    );

    if (!showInlineThumbnails) return text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: text),
        const SizedBox(width: 8),
        CartProductThumbnail(size: thumbnailSize),
      ],
    );
  }

  Widget _footerLine(String line) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        line,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          color: CustomersLoginThemeView.quantityAccent,
        ),
      ),
    );
  }
}
