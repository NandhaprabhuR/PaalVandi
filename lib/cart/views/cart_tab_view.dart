import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/models/home_catalog_data.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/cart_models.dart';
import '../viewmodels/cart_scope.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/cart_product_thumbnail.dart';
import '../../payment/views/payment_selection_view.dart';
import 'detailed_bill_view.dart';
import 'bottle_wallet_history_view.dart';
import 'order_history_view.dart';

class CartTabView extends StatelessWidget {
  const CartTabView({super.key});

  static BoxDecoration get _itemDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);

    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _cartAppBar(context, cart),
          body: cart.items.isEmpty
              ? _emptyBody()
              : Column(
                  children: [
                    Expanded(child: _cartList(context, cart)),
                    _CheckoutBar(cart: cart),
                  ],
                ),
        );
      },
    );
  }

  Widget _emptyBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: CustomersLoginThemeView.titleStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + on a product to order',
            style: CustomersLoginThemeView.subtitleStyle,
          ),
        ],
      ),
    );
  }

  Widget _cartList(BuildContext context, CartViewModel cart) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = cart.items[i];
        return _CartItemCard(
          key: ValueKey(
            '${item.productName}_${item.quantity}_${item.count}_${item.deliveryMethod}_$i',
          ),
          item: item,
          onIncrement: () => cart.incrementCount(i),
          onDecrement: () => _handleDecrement(context, cart, i),
          onRemove: () => _confirmRemove(context, cart, i),
          onVariantChanged: (variant) => cart.updateVariant(
            i,
            variant.quantity,
            variant.priceRupees,
          ),
          onDeliveryMethodChanged: (method) =>
              cart.updateDeliveryMethod(i, method),
        );
      },
    );
  }

  PreferredSizeWidget _cartAppBar(BuildContext context, CartViewModel cart) {
    final pending = cart.pendingBottlesCount;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CartScope(
                store: cart,
                child: const BottleWalletHistoryView(),
              ),
            ),
          );
        },
        icon: Badge(
          isLabelVisible: pending > 0,
          label: Text(
            '$pending',
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
          child: const Icon(
            Icons.local_drink_outlined,
            color: CustomersLoginThemeView.primaryBlue,
          ),
        ),
      ),
      title: Text(
        'Cart',
        style: CustomersLoginThemeView.brandTitleStyle.copyWith(
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CartScope(
                  store: cart,
                  child: const OrderHistoryView(),
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.history,
            size: 20,
            color: CustomersLoginThemeView.primaryBlue,
          ),
          label: Text(
            'History',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: CustomersLoginThemeView.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDecrement(
    BuildContext context,
    CartViewModel cart,
    int index,
  ) async {
    if (cart.items[index].count > 1) {
      cart.decrementCount(index);
      return;
    }
    await _confirmRemove(context, cart, index);
  }

  Future<void> _confirmRemove(
    BuildContext context,
    CartViewModel cart,
    int index,
  ) async {
    final name = cart.items[index].productName;
    final remove = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _RemoveItemDialog(productName: name),
    );
    if (remove == true) cart.removeAt(index);
  }

  static void _proceedToPay(BuildContext context, CartViewModel cart) {
    if (cart.items.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScope(
          store: cart,
          child: const PaymentSelectionView(),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartLineItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final ValueChanged<HomeProductItem> onVariantChanged;
  final ValueChanged<DeliveryMethod> onDeliveryMethodChanged;

  const _CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onVariantChanged,
    required this.onDeliveryMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final variants = HomeCatalogData.variantsForProduct(item.productName);

    return Container(
      decoration: CartTabView._itemDecoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: CustomersLoginThemeView.textDark,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${item.lineTotalRupees}',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: CustomersLoginThemeView.priceAccent,
                      height: 1.0,
                    ),
                  ),
                  if (item.count > 1)
                    Text(
                      '₹${item.unitTotalRupees} × ${item.count}',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: CustomersLoginThemeView.textGrey,
                        height: 1.1,
                      ),
                    ),
                  const SizedBox(height: 4),
                  _DeliveryMethodDropdown(
                    method: item.deliveryMethod,
                    depositTotalRupees: item.totalDepositRupees,
                    onSelected: onDeliveryMethodChanged,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _VolumeDropdown(
                quantity: item.quantity,
                variants: variants,
                itemCount: item.count,
                onSelected: onVariantChanged,
              ),
            ),
            const SizedBox(width: 6),
            _QuantityStepper(
              count: item.count,
              onDecrement: onDecrement,
              onIncrement: onIncrement,
            ),
            const SizedBox(width: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const CartProductThumbnail(size: 64),
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: CustomersLoginThemeView.textGrey
                            .withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoveItemDialog extends StatelessWidget {
  final String productName;

  const _RemoveItemDialog({required this.productName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remove item?',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CustomersLoginThemeView.primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Are you sure you want to remove $productName from your cart?',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CustomersLoginThemeView.textGrey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CustomersLoginThemeView.primaryBlue,
                      side: const BorderSide(
                        color: CustomersLoginThemeView.primaryBlue,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'No',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomersLoginThemeView.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Yes',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryMethodDropdown extends StatelessWidget {
  final DeliveryMethod method;
  final int depositTotalRupees;
  final ValueChanged<DeliveryMethod> onSelected;

  const _DeliveryMethodDropdown({
    required this.method,
    required this.depositTotalRupees,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DeliveryMethod>(
      onSelected: onSelected,
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => DeliveryMethod.values
          .map(
            (m) => PopupMenuItem(
              value: m,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.label,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: m == method
                          ? CustomersLoginThemeView.primaryBlue
                          : CustomersLoginThemeView.textDark,
                    ),
                  ),
                  if (m == DeliveryMethod.depositBottle)
                    Text(
                      '+ ₹${CartLineItem.glassBottleDepositRupees} per bottle',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: CustomersLoginThemeView.quantityAccent,
                      ),
                    )
                  else
                    Text(
                      'No glass bottle deposit',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: CustomersLoginThemeView.textGrey,
                      ),
                    ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 168),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: method == DeliveryMethod.depositBottle
                ? CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.45)
                : CustomersLoginThemeView.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: CustomersLoginThemeView.quantityAccent,
                      height: 1.15,
                    ),
                  ),
                  if (method == DeliveryMethod.depositBottle &&
                      depositTotalRupees > 0)
                    Text(
                      '+ ₹$depositTotalRupees',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: CustomersLoginThemeView.priceAccent,
                        height: 1.1,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: CustomersLoginThemeView.textGrey.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _VolumeDropdown extends StatelessWidget {
  final String quantity;
  final List<HomeProductItem> variants;
  final int itemCount;
  final ValueChanged<HomeProductItem> onSelected;

  const _VolumeDropdown({
    required this.quantity,
    required this.variants,
    required this.itemCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = variants.isNotEmpty
        ? variants
        : [HomeProductItem(quantity: quantity, price: '', priceRupees: 0)];

    return PopupMenuButton<HomeProductItem>(
      onSelected: onSelected,
      offset: const Offset(0, 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => options
          .map(
            (v) => PopupMenuItem(
              value: v,
              child: Row(
                children: [
                  Text(
                    v.quantity,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: v.quantity == quantity
                          ? CustomersLoginThemeView.quantityAccent
                          : CustomersLoginThemeView.textDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    v.price,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CustomersLoginThemeView.priceAccent,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Badge(
        isLabelVisible: itemCount > 0,
        label: Text(
          '$itemCount',
          style: const TextStyle(fontSize: 10),
        ),
        backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: itemCount > 1
                  ? CustomersLoginThemeView.primaryBlue
                  : CustomersLoginThemeView.borderColor,
              width: itemCount > 1 ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                quantity,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CustomersLoginThemeView.quantityAccent,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: CustomersLoginThemeView.textGrey.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int count;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityStepper({
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CustomersLoginThemeView.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepButton(Icons.remove, onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$count',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: CustomersLoginThemeView.primaryBlue,
              ),
            ),
          ),
          _stepButton(Icons.add, onIncrement),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 15, color: CustomersLoginThemeView.primaryBlue),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final CartViewModel cart;

  const _CheckoutBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: CustomersLoginThemeView.borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'To Pay',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: CustomersLoginThemeView.textGrey,
                ),
              ),
              const Spacer(),
              Text(
                '₹${cart.toPayRupees}',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.priceAccent,
                ),
              ),
            ],
          ),
          Text(
            'Incl. ₹${cart.deliveryChargeRupeesApplied} delivery · ${cart.totalProductCount} items',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: CustomersLoginThemeView.textGrey,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DetailedBillView(cart: cart),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: CustomersLoginThemeView.primaryBlue,
              side: const BorderSide(color: CustomersLoginThemeView.primaryBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'View detailed bill',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => CartTabView._proceedToPay(context, cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomersLoginThemeView.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Proceed to Pay',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
