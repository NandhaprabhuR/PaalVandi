import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cart/models/cart_models.dart';
import '../../cart/viewmodels/cart_scope.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/home_catalog_data.dart';

Future<void> showProductOrderBottomSheet(
  BuildContext context, {
  required String productName,
  required HomeProductItem item,
  required bool showDepositBadge,
  required bool showRefillBadge,
}) {
  final cart = CartScope.of(context);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ProductOrderSheet(
      cart: cart,
      productName: productName,
      item: item,
      showDepositBadge: showDepositBadge,
      showRefillBadge: showRefillBadge,
    ),
  );
}

class _ProductOrderSheet extends StatefulWidget {
  final CartViewModel cart;
  final String productName;
  final HomeProductItem item;
  final bool showDepositBadge;
  final bool showRefillBadge;

  const _ProductOrderSheet({
    required this.cart,
    required this.productName,
    required this.item,
    required this.showDepositBadge,
    required this.showRefillBadge,
  });

  @override
  State<_ProductOrderSheet> createState() => _ProductOrderSheetState();
}

class _ProductOrderSheetState extends State<_ProductOrderSheet> {

  DeliveryMethod _method = DeliveryMethod.depositBottle;

  bool get _isRefill => _method == DeliveryMethod.bringMyContainer;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: CustomersLoginThemeView.primaryBlue, width: 2),
            left: BorderSide(color: CustomersLoginThemeView.primaryBlue, width: 1.2),
            right: BorderSide(color: CustomersLoginThemeView.primaryBlue, width: 1.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CustomersLoginThemeView.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProductHeader(),
                    const SizedBox(height: 16),
                    const Divider(color: CustomersLoginThemeView.borderColor),
                    const SizedBox(height: 16),
                    Text(
                      'Select Delivery Method',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DeliveryOptionCard(
                      selected: _method == DeliveryMethod.depositBottle,
                      onTap: () => setState(
                        () => _method = DeliveryMethod.depositBottle,
                      ),
                      emoji: '🥛',
                      title: 'Deposit Bottle',
                      subtitle: 'Reusable glass bottle delivery',
                      priceLines: [
                        'Milk Price: ${widget.item.price}',
                        'Bottle Deposit: ₹${CartLineItem.glassBottleDepositRupees}',
                        'Total: ₹${widget.item.priceRupees + CartLineItem.glassBottleDepositRupees}',
                      ],
                      description:
                          'Return bottle anytime and get deposit refund.',
                      features: const [
                        '♻ Reusable',
                        '🌿 Eco Friendly',
                        '💧 Premium Glass Delivery',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DeliveryOptionCard(
                      selected: _method == DeliveryMethod.bringMyContainer,
                      onTap: () => setState(
                        () => _method = DeliveryMethod.bringMyContainer,
                      ),
                      emoji: '🥣',
                      title: 'Bring My Container',
                      subtitle:
                          "Delivery partner fills customer's own container.",
                      priceLines: [
                        'Milk Price: ${widget.item.price}',
                        'No bottle charge.',
                      ],
                      description:
                          'Use your own milk container for delivery.',
                      features: const [
                        '💰 No deposit amount',
                        '🌿 Zero waste',
                        '🥛 Refill service',
                      ],
                    ),
                    SizedBox(height: 88 + bottomInset),
                  ],
                ),
              ),
            ),
            _buildContinueBar(bottomInset),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.25),
            ),
          ),
          child: const Icon(
            Icons.local_drink_outlined,
            size: 40,
            color: CustomersLoginThemeView.primaryBlue,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.productName,
                style: GoogleFonts.montserrat(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
              Text(
                widget.item.quantity,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CustomersLoginThemeView.primaryBlue,
                ),
              ),
              Text(
                widget.item.price,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.textDark,
                ),
              ),
              if (widget.showDepositBadge || widget.showRefillBadge) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (widget.showDepositBadge)
                      _miniBadge('♻ Glass Return Available'),
                    if (widget.showRefillBadge)
                      _miniBadge('🥣 Refill Available'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: CustomersLoginThemeView.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildContinueBar(double bottomInset) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomersLoginThemeView.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _onContinue,
          child: Text(
            'Continue',
            style: CustomersLoginThemeView.buttonTextStyle.copyWith(fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    widget.cart.addItem(
      CartLineItem(
        productName: widget.productName,
        quantity: widget.item.quantity,
        milkPriceRupees: widget.item.priceRupees,
        deliveryMethod: _method,
        bottleDepositRupees: _isRefill
            ? null
            : CartLineItem.glassBottleDepositRupees,
      ),
    );
    Navigator.of(context).pop();
  }
}

class _DeliveryOptionCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String emoji;
  final String title;
  final String subtitle;
  final List<String> priceLines;
  final String description;
  final List<String> features;

  const _DeliveryOptionCard({
    required this.selected,
    required this.onTap,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.priceLines,
    required this.description,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? CustomersLoginThemeView.primaryBlue
              : CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.25),
          width: selected ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: selected ? 0.08 : 0.05),
            blurRadius: selected ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: CustomersLoginThemeView.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: CustomersLoginThemeView.textGrey,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...priceLines.map(
                        (line) => Text(
                          line,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: CustomersLoginThemeView.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: CustomersLoginThemeView.textGrey,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            f,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: CustomersLoginThemeView.textDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: CustomersLoginThemeView.primaryBlue,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
