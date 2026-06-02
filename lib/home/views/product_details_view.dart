import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../cart/viewmodels/cart_scope.dart';
import '../../../theme/customers_login_themeview.dart';
import '../../../core/widgets/responsive_helper.dart';
import '../../../core/app_route_storage.dart';
import '../../../bottomnavigation/views/bottom_navigation_view.dart';
import '../models/home_catalog_data.dart';
import 'product_reviews_view.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/shimmer_loading.dart';

class ProductDetailsView extends StatefulWidget {
  final String productName;
  final HomeProductItem initialItem;

  const ProductDetailsView({
    super.key,
    required this.productName,
    required this.initialItem,
  });

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  late HomeProductItem _selectedItem;
  late final List<HomeProductItem> _variants;
  bool _isLocalLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialItem;
    _variants = HomeCatalogData.variantsForProduct(widget.productName);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLocalLoading = false;
        });
      }
    });
  }

  Color _getAvatarTint(String emoji) {
    if (emoji == '👩‍🦰') return const Color(0xFFF3E5F5); // Tinted Lavender
    if (emoji == '🧔') return const Color(0xFFFFF3E0); // Tinted Orange
    if (emoji == '👳') return const Color(0xFFE8F5E9); // Tinted Green
    if (emoji == '👱‍♀️') return const Color(0xFFFCE4EC); // Tinted Pink
    return const Color(0xFFE3F2FD); // Default Tinted Blue
  }

  // Splitting quantity like 500ml -> 500 and ml
  Map<String, String> _splitQuantity(String qty) {
    final numberPart = RegExp(r'^\d+(\.\d+)?').stringMatch(qty) ?? qty;
    final unitPart = qty.substring(numberPart.length);
    return {
      'number': numberPart,
      'unit': unitPart,
    };
  }

  // Determine dynamic kcal count based on quantity size for visual accuracy
  String _getEnergyKcal(String qty) {
    if (qty.contains('100ml')) return '42';
    if (qty.contains('250ml')) return '105';
    if (qty.contains('500ml')) return '210';
    if (qty.contains('750ml')) return '315';
    if (qty.contains('1L')) return '420';
    if (qty.contains('1.5L')) return '630';
    if (qty.contains('2L')) return '840';
    if (qty.contains('200g')) return '120';
    if (qty.contains('500g')) return '300';
    if (qty.contains('1kg')) return '600';
    return '42';
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    // Determine correct product image
    final isCurd = widget.productName.contains('Curd');
    final String imagePath = isCurd ? 'assets/allbottles.png' : 'assets/allbottles.png';

    // Splitting quantity details
    final qtySplit = _splitQuantity(_selectedItem.quantity);
    final energyKcal = _getEnergyKcal(_selectedItem.quantity);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CustomersLoginThemeView.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.productName,
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(22),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLocalLoading
          ? _buildProductDetailsSkeleton(context, hPadding, scaleF, fs)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(10)),
              children: [
                // Top Split Layout (Left stats column, Right standing image)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaleF(20)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column for Stats & Stepper chip
                      Expanded(
                        flex: 4,
                        child: AnimatedBuilder(
                          animation: cart,
                          builder: (context, _) {
                            final count = cart.countInCart(widget.productName, _selectedItem.quantity);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: scaleF(10)),
                                // Packaging
                                Text(
                                  'Packaging',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(11),
                                    fontWeight: FontWeight.w600,
                                    color: CustomersLoginThemeView.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${qtySplit['number']} ',
                                        style: GoogleFonts.montserrat(
                                          fontSize: fs(24),
                                          fontWeight: FontWeight.w800,
                                          color: CustomersLoginThemeView.textDark,
                                        ),
                                      ),
                                      TextSpan(
                                        text: qtySplit['unit'],
                                        style: GoogleFonts.montserrat(
                                          fontSize: fs(14),
                                          fontWeight: FontWeight.bold,
                                          color: CustomersLoginThemeView.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: scaleF(16)),

                                // Energy
                                Text(
                                  'Energy',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(11),
                                    fontWeight: FontWeight.w600,
                                    color: CustomersLoginThemeView.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '$energyKcal ',
                                        style: GoogleFonts.montserrat(
                                          fontSize: fs(24),
                                          fontWeight: FontWeight.w800,
                                          color: CustomersLoginThemeView.textDark,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'kcal',
                                        style: GoogleFonts.montserrat(
                                          fontSize: fs(14),
                                          fontWeight: FontWeight.bold,
                                          color: CustomersLoginThemeView.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: scaleF(16)),

                                // Price
                                Text(
                                  'Price',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(11),
                                    fontWeight: FontWeight.w600,
                                    color: CustomersLoginThemeView.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedItem.price,
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(26),
                                    fontWeight: FontWeight.w900,
                                    color: CustomersLoginThemeView.textDark,
                                  ),
                                ),
                                SizedBox(height: scaleF(24)),

                                // Stepper Chip directly under Stats
                                _selectedItem.stockStatus == 'Out of Stock'
                                    ? Container(
                                        width: scaleF(108),
                                        height: scaleF(36),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(color: Colors.grey.shade400, width: 1),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Sold Out',
                                          style: GoogleFonts.montserrat(
                                            fontSize: fs(11),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: scaleF(108),
                                        height: scaleF(36),
                                        decoration: BoxDecoration(
                                          color: CustomersLoginThemeView.primaryBlue,
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                                              onPressed: () {
                                                HapticService.lightImpact();
                                                cart.decrementFromHome(widget.productName, _selectedItem.quantity);
                                              },
                                            ),
                                            Text(
                                              '$count',
                                              style: GoogleFonts.montserrat(
                                                fontSize: fs(14),
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                              onPressed: () {
                                                HapticService.lightImpact();
                                                cart.addFromHome(widget.productName, _selectedItem);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Right Column for Product standing image
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: EdgeInsets.only(top: scaleF(10)),
                          alignment: Alignment.center,
                          child: Hero(
                            tag: 'product_${widget.productName}',
                            child: Image.asset(
                              imagePath,
                              height: scaleF(220).clamp(180.0, 260.0),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleF(24)),

                // Variant selector inside lists so users can select volumes beautifully
                Text(
                  'Select Variant',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    fontWeight: FontWeight.bold,
                    color: CustomersLoginThemeView.textDark,
                  ),
                ),
                SizedBox(height: scaleF(8)),
                Wrap(
                  spacing: scaleF(8),
                  runSpacing: scaleF(8),
                  children: _variants.map((v) {
                    final isSelected = v.quantity == _selectedItem.quantity;
                    return ChoiceChip(
                      label: Text(v.quantity),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedItem = v);
                          HapticService.selection();
                        }
                      },
                      selectedColor: CustomersLoginThemeView.primaryBlue.withOpacity(0.08),
                      checkmarkColor: CustomersLoginThemeView.primaryBlue,
                      backgroundColor: Colors.grey.shade50,
                      side: BorderSide(
                        color: isSelected
                            ? CustomersLoginThemeView.primaryBlue
                            : CustomersLoginThemeView.borderColor.withOpacity(0.4),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      labelStyle: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? CustomersLoginThemeView.primaryBlue
                            : CustomersLoginThemeView.textDark,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: scaleF(20)),
                const Divider(height: 1),
                SizedBox(height: scaleF(16)),

                 // Product Name and Star Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.productName,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(18),
                              fontWeight: FontWeight.w800,
                              color: CustomersLoginThemeView.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Stock status and packaging tags
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _selectedItem.stockStatus == 'Out of Stock'
                                      ? const Color(0xFFD32F2F)
                                      : (_selectedItem.stockStatus == 'Low Stock'
                                          ? const Color(0xFFF57C00)
                                          : const Color(0xFF388E3C)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _selectedItem.stockStatus,
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(8),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.productName.contains('Curd')
                                    ? '🥣 Refill Available'
                                    : '♻ Deposit Bottle Available',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(10),
                                  fontWeight: FontWeight.bold,
                                  color: CustomersLoginThemeView.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              '⭐ ${_selectedItem.rating.toStringAsFixed(1)} ',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(14),
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                            Text(
                              '(${_selectedItem.totalOrders})',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(10),
                                fontWeight: FontWeight.w600,
                                color: CustomersLoginThemeView.textGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        AnimatedBuilder(
                          animation: cart,
                          builder: (context, _) {
                            final productReviews = cart.productReviews
                                .where((r) => r.productName == widget.productName)
                                .toList();
                            final double avgRating = productReviews.isEmpty
                                ? 0.0
                                : productReviews.map((r) => r.rating).reduce((a, b) => a + b) / productReviews.length;

                            return Row(
                              children: List.generate(5, (index) {
                                final double val = index + 1.0;
                                return Icon(
                                  val <= avgRating
                                      ? Icons.star_rounded
                                      : (val - 0.5 <= avgRating
                                          ? Icons.star_half_rounded
                                          : Icons.star_border_rounded),
                                  color: Colors.amber,
                                  size: fs(16),
                                );
                              }),
                            );
                          }
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: scaleF(8)),

                // Description
                Text(
                  'It is pasteurized in state of the art processing plant and packed to make it conveniently available to consumers. Sourced fresh daily with zero water or preservative additions.',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    fontWeight: FontWeight.w500,
                    color: CustomersLoginThemeView.textGrey,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: scaleF(24)),

                // Reviews Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reviews',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CartScope(
                              store: cart,
                              child: ProductReviewsView(productName: widget.productName),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'View all',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          fontWeight: FontWeight.bold,
                          color: CustomersLoginThemeView.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: scaleF(12)),

                // Horizontal list of review avatars
                AnimatedBuilder(
                  animation: cart,
                  builder: (context, _) {
                    final productReviews = cart.productReviews
                        .where((r) => r.productName == widget.productName)
                        .toList();

                    return Row(
                      children: [
                        ...productReviews.take(4).map((review) {
                          return Padding(
                            padding: EdgeInsets.only(right: scaleF(10)),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CartScope(
                                      store: cart,
                                      child: ProductReviewsView(productName: widget.productName),
                                    ),
                                  ),
                                );
                              },
                              child: _buildAvatarTile(review.userEmoji, _getAvatarTint(review.userEmoji)),
                            ),
                          );
                        }),
                        // Dashed Rounded circular plus button to write review!
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CartScope(
                                  store: cart,
                                  child: ProductReviewsView(productName: widget.productName),
                                ),
                              ),
                            );
                          },
                          child: CustomPaint(
                            painter: DashedBorderPainter(color: Colors.grey.shade400),
                            child: Container(
                              width: scaleF(46),
                              height: scaleF(46),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add, color: Colors.grey, size: 20),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                ),
                SizedBox(height: scaleF(20)),
              ],
            ),
          ),

          // Sticky Bottom Checkout Banner Actions Bar (Dynamic)
          AnimatedBuilder(
            animation: cart,
            builder: (context, _) {
              final count = cart.countInCart(widget.productName, _selectedItem.quantity);

              // Calculate prices dynamically
              final double unitPrice = _selectedItem.priceRupees.toDouble();
              final double calculatedTotal = count == 0 ? unitPrice : (unitPrice * count);

              if (_selectedItem.stockStatus == 'Out of Stock') {
                return Container(
                  padding: EdgeInsets.fromLTRB(hPadding, scaleF(12), hPadding, scaleF(16) + MediaQuery.paddingOf(context).bottom),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: CustomersLoginThemeView.borderColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Price',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(11),
                              fontWeight: FontWeight.w600,
                              color: CustomersLoginThemeView.textGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${calculatedTotal.toStringAsFixed(2)}',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(18),
                              fontWeight: FontWeight.w900,
                              color: CustomersLoginThemeView.textDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: scaleF(140),
                        height: scaleF(44),
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey.shade500,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Sold Out',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(13),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (count == 0) {
                // Split row layout showing Total Price and Add to Cart button
                return Container(
                  padding: EdgeInsets.fromLTRB(hPadding, scaleF(12), hPadding, scaleF(16) + MediaQuery.paddingOf(context).bottom),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: CustomersLoginThemeView.borderColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Price',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(11),
                              fontWeight: FontWeight.w600,
                              color: CustomersLoginThemeView.textGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${calculatedTotal.toStringAsFixed(2)}',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(18),
                              fontWeight: FontWeight.w900,
                              color: CustomersLoginThemeView.textDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: scaleF(140),
                        height: scaleF(44),
                        child: ElevatedButton(
                          onPressed: () {
                            HapticService.mediumImpact();
                            cart.addFromHome(widget.productName, _selectedItem);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomersLoginThemeView.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Add to Cart',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(13),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Sourced Blue Added to Cart Banner containing Stepper &
                return Container(
                  padding: EdgeInsets.fromLTRB(hPadding, scaleF(7), hPadding, scaleF(7) + MediaQuery.paddingOf(context).bottom),
                  decoration: const BoxDecoration(
                    color: CustomersLoginThemeView.primaryBlue,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Added to cart',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(13),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${count}x ${_selectedItem.quantity} selected',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(11),
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Outlined White Stepper Control Chip
                      Container(
                        height: scaleF(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              icon: const Icon(Icons.remove, size: 14, color: Colors.white),
                              onPressed: () {
                                HapticService.lightImpact();
                                cart.decrementFromHome(widget.productName, _selectedItem.quantity);
                              },
                            ),
                            Text(
                              '$count',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              icon: const Icon(Icons.add, size: 14, color: Colors.white),
                              onPressed: () {
                                HapticService.lightImpact();
                                cart.addFromHome(widget.productName, _selectedItem);
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(width: scaleF(10)),

                      // Compact Premium White-Border-less View Cart Button (Matches Home AddedToCartBar style)
                      TextButton(
                        onPressed: () async {
                          if (BottomNavigationView.onSelectTabGlobal != null) {
                            BottomNavigationView.onSelectTabGlobal!(1);
                          }
                          await AppRouteStorage.saveHomeTabIndex(1);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.22),
                          minimumSize: Size(0, scaleF(32)),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.symmetric(
                            horizontal: scaleF(12),
                            vertical: scaleF(4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'View Cart',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsSkeleton(
    BuildContext context,
    double hPadding,
    double Function(double) scaleF,
    double Function(double) fs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(10)),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: scaleF(20)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: scaleF(10)),
                          const ShimmerSkeleton(width: 70, height: 10, borderRadius: 2),
                          const SizedBox(height: 4),
                          const ShimmerSkeleton(width: 80, height: 22, borderRadius: 3),
                          SizedBox(height: scaleF(16)),
                          const ShimmerSkeleton(width: 50, height: 10, borderRadius: 2),
                          const SizedBox(height: 4),
                          const ShimmerSkeleton(width: 90, height: 22, borderRadius: 3),
                          SizedBox(height: scaleF(16)),
                          const ShimmerSkeleton(width: 40, height: 10, borderRadius: 2),
                          const SizedBox(height: 4),
                          const ShimmerSkeleton(width: 85, height: 24, borderRadius: 3),
                          SizedBox(height: scaleF(24)),
                          ShimmerSkeleton(width: scaleF(108), height: scaleF(36), borderRadius: 18),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: EdgeInsets.only(top: scaleF(10)),
                        alignment: Alignment.center,
                        child: ShimmerSkeleton(
                          width: scaleF(160),
                          height: scaleF(220),
                          borderRadius: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: scaleF(24)),

              const ShimmerSkeleton(width: 100, height: 12, borderRadius: 3),
              SizedBox(height: scaleF(8)),
              Row(
                children: [
                  ShimmerSkeleton(width: scaleF(70), height: scaleF(32), borderRadius: 16),
                  const SizedBox(width: 8),
                  ShimmerSkeleton(width: scaleF(70), height: scaleF(32), borderRadius: 16),
                  const SizedBox(width: 8),
                  ShimmerSkeleton(width: scaleF(70), height: scaleF(32), borderRadius: 16),
                ],
              ),
              SizedBox(height: scaleF(20)),
              const Divider(height: 1),
              SizedBox(height: scaleF(16)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerSkeleton(width: 160, height: 18, borderRadius: 3),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const ShimmerSkeleton(width: 60, height: 14, borderRadius: 10),
                            const SizedBox(width: 8),
                            ShimmerSkeleton(width: scaleF(130), height: scaleF(10), borderRadius: 3),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Row(
                        children: [
                          ShimmerSkeleton(width: 45, height: 14, borderRadius: 3),
                          SizedBox(width: 4),
                          ShimmerSkeleton(width: 30, height: 10, borderRadius: 3),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) => const Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: ShimmerSkeleton(width: 14, height: 14, borderRadius: 7),
                        )),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: scaleF(12)),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerSkeleton(width: double.infinity, height: 11, borderRadius: 2),
                  const SizedBox(height: 4),
                  const ShimmerSkeleton(width: double.infinity, height: 11, borderRadius: 2),
                  const SizedBox(height: 4),
                  ShimmerSkeleton(width: scaleF(180), height: scaleF(11), borderRadius: 2),
                ],
              ),
              SizedBox(height: scaleF(24)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerSkeleton(width: scaleF(80), height: scaleF(14), borderRadius: 3),
                  ShimmerSkeleton(width: scaleF(60), height: scaleF(12), borderRadius: 3),
                ],
              ),
              SizedBox(height: scaleF(12)),

              Row(
                children: [
                  ShimmerSkeleton(width: scaleF(46), height: scaleF(46), borderRadius: 10),
                  SizedBox(width: scaleF(10)),
                  ShimmerSkeleton(width: scaleF(46), height: scaleF(46), borderRadius: 10),
                  SizedBox(width: scaleF(10)),
                  ShimmerSkeleton(width: scaleF(46), height: scaleF(46), borderRadius: 10),
                  SizedBox(width: scaleF(10)),
                  ShimmerSkeleton(width: scaleF(46), height: scaleF(46), borderRadius: 10),
                ],
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.fromLTRB(hPadding, scaleF(12), hPadding, scaleF(16) + MediaQuery.paddingOf(context).bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08), width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerSkeleton(width: scaleF(60), height: scaleF(10), borderRadius: 2),
                  const SizedBox(height: 4),
                  ShimmerSkeleton(width: scaleF(80), height: scaleF(18), borderRadius: 3),
                ],
              ),
              ShimmerSkeleton(width: scaleF(140), height: scaleF(44), borderRadius: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarTile(String emoji, Color tintColor) {
    final tileWidth = ResponsiveHelper.scaledValue(context, 46);
    return Container(
      width: tileWidth,
      height: tileWidth,
      decoration: BoxDecoration(
        color: tintColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 22),
      ),
    );
  }
}

// Dashed Border Painter for the Reviews add button
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.5,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(10),
      ));

    for (PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double nextDistance = distance + gap;
        canvas.drawPath(
          metric.extractPath(distance, nextDistance),
          paint,
        );
        distance = nextDistance + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
