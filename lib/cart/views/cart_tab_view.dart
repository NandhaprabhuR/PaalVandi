import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/models/home_catalog_data.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../models/cart_models.dart';
import '../viewmodels/cart_scope.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/cart_product_thumbnail.dart';
import '../../payment/views/payment_selection_view.dart';
import 'detailed_bill_view.dart';
import 'bottle_wallet_history_view.dart';
import 'order_history_view.dart';
import '../../bottomnavigation/views/bottom_navigation_view.dart';
import '../../core/services/haptic_service.dart';

import '../../core/widgets/shimmer_loading.dart';

class CartTabView extends StatefulWidget {
  const CartTabView({super.key});

  static BoxDecoration get _itemDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      );

  static void _proceedToPay(BuildContext context, CartViewModel cart) {
    if (cart.items.isEmpty) return;
    HapticService.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScope(
          store: cart,
          child: const PaymentSelectionView(),
        ),
      ),
    );
  }

  @override
  State<CartTabView> createState() => _CartTabViewState();
}

class _CartTabViewState extends State<CartTabView> {
  bool _isLocalLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate high-fidelity skeleton loading delay of 1 second
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLocalLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
          appBar: widget._cartAppBar(context, cart),
          body: _isLocalLoading
              ? _buildCartSkeleton(context, hPadding, scaleF, fs)
              : (cart.items.isEmpty
                  ? widget._emptyBody(context)
                  : Column(
                      children: [
                        Expanded(child: widget._cartList(context, cart)),
                        _CheckoutBar(cart: cart),
                      ],
                    )),
        );
      },
    );
  }

  Widget _buildCartSkeleton(
    BuildContext context,
    double hPadding,
    double Function(double) scaleF,
    double Function(double) fs,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(hPadding, scaleF(12), hPadding, scaleF(8)),
            itemCount: 2,
            separatorBuilder: (_, __) => SizedBox(height: scaleF(10)),
            itemBuilder: (context, index) {
              return Container(
                decoration: CartTabView._itemDecoration,
                padding: EdgeInsets.symmetric(horizontal: scaleF(10), vertical: scaleF(8)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerSkeleton(width: scaleF(140), height: scaleF(14), borderRadius: 3),
                          SizedBox(height: scaleF(12)),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShimmerSkeleton(width: scaleF(60), height: scaleF(16), borderRadius: 3),
                                  SizedBox(height: scaleF(6)),
                                  ShimmerSkeleton(width: scaleF(110), height: scaleF(10), borderRadius: 3),
                                ],
                              ),
                              const Spacer(),
                              ShimmerSkeleton(width: scaleF(54), height: scaleF(24), borderRadius: 12),
                              SizedBox(width: scaleF(8)),
                              ShimmerSkeleton(width: scaleF(68), height: scaleF(24), borderRadius: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: scaleF(8)),
                    ShimmerSkeleton(width: scaleF(64), height: scaleF(64), borderRadius: 14),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(hPadding, scaleF(10), hPadding, scaleF(10) + MediaQuery.paddingOf(context).bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.1))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerSkeleton(width: scaleF(80), height: scaleF(12), borderRadius: 3),
                  ShimmerSkeleton(width: scaleF(100), height: scaleF(16), borderRadius: 3),
                ],
              ),
              SizedBox(height: scaleF(12)),
              ShimmerSkeleton(width: double.infinity, height: scaleF(44), borderRadius: 12),
            ],
          ),
        ),
      ],
    );
  }
}

extension on CartTabView {

  Widget _emptyBody(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, scaleF(20)),
            child: Lottie.asset(
              'assets/animations/noitemincart.json',
              width: scaleF(180),
              height: scaleF(180),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 0),
          Text(
            'Your cart is empty',
            style: CustomersLoginThemeView.titleStyle.copyWith(fontSize: fs(18)),
          ),
          SizedBox(height: scaleF(8)),
          Text(
            'Tap + on a product to order',
            style: CustomersLoginThemeView.subtitleStyle.copyWith(fontSize: fs(13)),
          ),
          SizedBox(height: scaleF(24)),
          InkWell(
            onTap: () {
              if (BottomNavigationView.onSelectTabGlobal != null) {
                BottomNavigationView.onSelectTabGlobal!(0);
              }
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: scaleF(52),
              height: scaleF(52),
              decoration: const BoxDecoration(
                color: CustomersLoginThemeView.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartList(BuildContext context, CartViewModel cart) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(hPadding, scaleF(4), hPadding, scaleF(8)),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => SizedBox(height: scaleF(10)),
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
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);

    return AppBar(
      backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
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
            style: TextStyle(fontSize: fs(10)),
          ),
          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
          child: Icon(
            Icons.local_drink_outlined,
            color: CustomersLoginThemeView.primaryBlue,
            size: scaleF(24).clamp(20.0, 28.0),
          ),
        ),
      ),
      title: Text(
        'Cart',
        style: CustomersLoginThemeView.brandTitleStyle.copyWith(
          fontSize: fs(22),
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
          icon: Icon(
            Icons.history,
            size: scaleF(20).clamp(16.0, 24.0),
            color: CustomersLoginThemeView.primaryBlue,
          ),
          label: Text(
            'History',
            style: GoogleFonts.montserrat(
              fontSize: fs(13),
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
    if (remove == true) {
      cart.removeAt(index);
      HapticService.warning();
    }
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
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    return Container(
      decoration: CartTabView._itemDecoration,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: scaleF(10), vertical: scaleF(8)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top: Product Name (occupies full width of Expanded column!)
                  Text(
                    item.productName,
                    maxLines: 1, // Full width, so 1 line is absolutely sufficient!
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.w700,
                      color: CustomersLoginThemeView.textDark,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: scaleF(8)),

                  // Bottom: Row containing Price/Dropdown, Volume, and Stepper!
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${item.lineTotalRupees}',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(15),
                                fontWeight: FontWeight.w800,
                                color: CustomersLoginThemeView.priceAccent,
                                height: 1.0,
                              ),
                            ),
                            if (item.count > 1) ...[
                              SizedBox(height: scaleF(2)),
                              Text(
                                '₹${item.unitTotalRupees} × ${item.count}',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(10),
                                  fontWeight: FontWeight.w500,
                                  color: CustomersLoginThemeView.textGrey,
                                  height: 1.1,
                                ),
                              ),
                            ],
                            SizedBox(height: scaleF(4)),
                            _DeliveryMethodDropdown(
                              method: item.deliveryMethod,
                              depositTotalRupees: item.totalDepositRupees,
                              onSelected: onDeliveryMethodChanged,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: scaleF(6)),
                        child: _VolumeDropdown(
                          quantity: item.quantity,
                          variants: variants,
                          itemCount: item.count,
                          onSelected: onVariantChanged,
                        ),
                      ),
                      SizedBox(width: scaleF(6)),
                      _QuantityStepper(
                        count: item.count,
                        onDecrement: onDecrement,
                        onIncrement: onIncrement,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: scaleF(8)),
            Stack(
              clipBehavior: Clip.none,
              children: [
                CartProductThumbnail(size: scaleF(64).clamp(54.0, 72.0)),
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
                        size: scaleF(16).clamp(12.0, 20.0),
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
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: scaleF(28)),
      child: Container(
        padding: EdgeInsets.fromLTRB(scaleF(20), scaleF(20), scaleF(20), scaleF(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remove item?',
              style: GoogleFonts.montserrat(
                fontSize: fs(18),
                fontWeight: FontWeight.w800,
                color: CustomersLoginThemeView.primaryBlue,
              ),
            ),
            SizedBox(height: scaleF(10)),
            Text(
              'Are you sure you want to remove $productName from your cart?',
              style: GoogleFonts.montserrat(
                fontSize: fs(14),
                fontWeight: FontWeight.w500,
                color: CustomersLoginThemeView.textGrey,
                height: 1.4,
              ),
            ),
            SizedBox(height: scaleF(20)),
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
                      padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                    ),
                    child: Text(
                      'No',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: scaleF(10)),
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
                      padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                    ),
                    child: Text(
                      'Yes',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
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
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    return PopupMenuButton<DeliveryMethod>(
      onSelected: (m) {
        HapticService.lightImpact();
        onSelected(m);
      },
      offset: Offset(0, scaleF(36)),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
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
                      fontSize: fs(12),
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
                        fontSize: fs(10),
                        color: CustomersLoginThemeView.quantityAccent,
                      ),
                    )
                  else
                    Text(
                      'No glass bottle deposit',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(10),
                        color: CustomersLoginThemeView.textGrey,
                      ),
                    ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        constraints: BoxConstraints(maxWidth: scaleF(168).clamp(135.0, 190.0)),
        padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(5)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black,
            width: 1,
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
                      fontSize: fs(9),
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
                        fontSize: fs(9),
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
              size: scaleF(16),
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
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    final options = variants.isNotEmpty
        ? variants
        : [HomeProductItem(quantity: quantity, price: '', priceRupees: 0)];

    return PopupMenuButton<HomeProductItem>(
      onSelected: (v) {
        HapticService.lightImpact();
        onSelected(v);
      },
      offset: Offset(0, scaleF(32)),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      itemBuilder: (context) => options
          .map(
            (v) => PopupMenuItem(
              value: v,
              child: Row(
                children: [
                  Text(
                    v.quantity,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(13),
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
                      fontSize: fs(12),
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
          style: TextStyle(fontSize: fs(10)),
        ),
        backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(4)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                quantity,
                style: GoogleFonts.montserrat(
                  fontSize: fs(11),
                  fontWeight: FontWeight.w600,
                  color: CustomersLoginThemeView.quantityAccent,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: scaleF(16),
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
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CustomersLoginThemeView.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepButton(context, Icons.remove, scaleF, onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$count',
              style: GoogleFonts.montserrat(
                fontSize: fs(12),
                fontWeight: FontWeight.w700,
                color: CustomersLoginThemeView.primaryBlue,
              ),
            ),
          ),
          _stepButton(context, Icons.add, scaleF, onIncrement),
        ],
      ),
    );
  }

  Widget _stepButton(BuildContext context, IconData icon, double Function(double) scaleF, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: EdgeInsets.all(scaleF(5).clamp(4.0, 8.0)),
        child: Icon(icon, size: scaleF(15).clamp(12.0, 18.0), color: CustomersLoginThemeView.primaryBlue),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final CartViewModel cart;

  const _CheckoutBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Container(
      padding: EdgeInsets.fromLTRB(hPadding, scaleF(10), hPadding, scaleF(10) + MediaQuery.paddingOf(context).bottom),
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
                  fontSize: fs(12),
                  color: CustomersLoginThemeView.textGrey,
                ),
              ),
              const Spacer(),
              Text(
                '₹${cart.toPayRupees}',
                style: GoogleFonts.montserrat(
                  fontSize: fs(20),
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.priceAccent,
                ),
              ),
            ],
          ),
          Text(
            'Incl. ₹${cart.deliveryChargeRupeesApplied} delivery · ${cart.totalProductCount} items',
            style: GoogleFonts.montserrat(
              fontSize: fs(10),
              color: CustomersLoginThemeView.textGrey,
            ),
          ),
          SizedBox(height: scaleF(10)),
          OutlinedButton(
            onPressed: () {
              HapticService.mediumImpact();
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
              padding: EdgeInsets.symmetric(vertical: scaleF(12)),
            ),
            child: Text(
              'View detailed bill',
              style: GoogleFonts.montserrat(
                fontSize: fs(14),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: scaleF(8)),
          SizedBox(
            height: scaleF(48).clamp(42.0, 54.0),
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
                  fontSize: fs(15),
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
