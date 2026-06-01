import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../cart/viewmodels/cart_scope.dart';
import '../../../cart/viewmodels/cart_viewmodel.dart';
import '../../../cart/models/product_review.dart';
import '../../../theme/customers_login_themeview.dart';
import '../../../core/widgets/responsive_helper.dart';

class ProductReviewsView extends StatefulWidget {
  final String productName;

  const ProductReviewsView({super.key, required this.productName});

  @override
  State<ProductReviewsView> createState() => _ProductReviewsViewState();
}

class _ProductReviewsViewState extends State<ProductReviewsView> {
  int _newRating = 5;
  final TextEditingController _commentController = TextEditingController();

  // Helper colors for avatar tints
  Color _getAvatarTint(String emoji) {
    if (emoji == '👩‍🦰') return const Color(0xFFF3E5F5); // Tinted Lavender
    if (emoji == '🧔') return const Color(0xFFFFF3E0); // Tinted Orange
    if (emoji == '👳') return const Color(0xFFE8F5E9); // Tinted Green
    if (emoji == '👱‍♀️') return const Color(0xFFFCE4EC); // Tinted Pink
    return const Color(0xFFE3F2FD); // Default Tinted Blue
  }

  void _showAddReviewBottomSheet(BuildContext context, CartViewModel cart, double Function(double) scaleF, double Function(double) fs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stateContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(stateContext).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(scaleF(20), scaleF(20), scaleF(20), scaleF(24)),
                decoration: BoxDecoration(
                  color: CustomersLoginThemeView.cardBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: scaleF(40),
                        height: scaleF(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: scaleF(16)),
                    Text(
                      'Write a Review 📝',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(18),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(4)),
                    Text(
                      'Share your feedback for ${widget.productName}',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12),
                        color: CustomersLoginThemeView.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: scaleF(20)),

                    // Stars rating selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        final isSelected = _newRating >= starValue;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _newRating = starValue;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: scaleF(8)),
                            child: Icon(
                              isSelected ? Icons.star : Icons.star_border,
                              color: isSelected ? Colors.amber : Colors.grey,
                              size: scaleF(36),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: scaleF(20)),

                    // Comment box
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe your experience with this product...',
                        hintStyle: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          color: CustomersLoginThemeView.textGrey,
                        ),
                        contentPadding: EdgeInsets.all(scaleF(12)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: CustomersLoginThemeView.primaryBlue, width: 1.5),
                        ),
                      ),
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12.5),
                        fontWeight: FontWeight.w500,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(24)),

                    // Submit button
                    GestureDetector(
                      onTap: () {
                        final comment = _commentController.text.trim();
                        cart.addProductReview(
                          ProductReview(
                            userName: 'Nandha Prabhu',
                            userEmoji: '👤',
                            rating: _newRating,
                            comment: comment.isEmpty ? 'Extremely fresh and healthy product! High quality.' : comment,
                            date: DateTime.now(),
                            productName: widget.productName,
                          ),
                        );
                        _commentController.clear();
                        Navigator.pop(sheetContext);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Review posted successfully! Thank you!',
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green.shade700,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: scaleF(14)),
                        decoration: BoxDecoration(
                          color: CustomersLoginThemeView.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            'Submit Review',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(14),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        final reviews = cart.productReviews
            .where((r) => r.productName == widget.productName)
            .toList();

        // Calculate average rating
        final double avgRating = reviews.isEmpty
            ? 0.0
            : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

        return Scaffold(
          backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: CustomersLoginThemeView.primaryBlue),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Product Reviews',
              style: GoogleFonts.montserrat(
                fontSize: fs(18),
                fontWeight: FontWeight.bold,
                color: CustomersLoginThemeView.primaryBlue,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
                  children: [
                    // Average rating overview banner card
                    Container(
                      padding: EdgeInsets.symmetric(vertical: scaleF(20), horizontal: scaleF(16)),
                      decoration: CustomersLoginThemeView.cardDecoration,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Average Rating',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(12),
                                    fontWeight: FontWeight.w600,
                                    color: CustomersLoginThemeView.textGrey,
                                  ),
                                ),
                                SizedBox(height: scaleF(6)),
                                Row(
                                  children: [
                                    Text(
                                      avgRating == 0.0 ? 'N/A' : avgRating.toStringAsFixed(1),
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(34),
                                        fontWeight: FontWeight.w900,
                                        color: CustomersLoginThemeView.textDark,
                                      ),
                                    ),
                                    SizedBox(width: scaleF(4)),
                                    Text(
                                      'out of 5',
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(12),
                                        fontWeight: FontWeight.w600,
                                        color: CustomersLoginThemeView.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: scaleF(6)),
                                Row(
                                  children: List.generate(5, (index) {
                                    final double val = index + 1.0;
                                    return Icon(
                                      val <= avgRating
                                          ? Icons.star_rounded
                                          : (val - 0.5 <= avgRating
                                              ? Icons.star_half_rounded
                                              : Icons.star_border_rounded),
                                      color: Colors.amber,
                                      size: fs(18),
                                    );
                                  }),
                                ),
                                SizedBox(height: scaleF(4)),
                                Text(
                                  'Based on ${reviews.length} customer reviews',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(11),
                                    fontWeight: FontWeight.w500,
                                    color: CustomersLoginThemeView.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1.5,
                            height: scaleF(80),
                            color: Colors.black.withOpacity(0.08),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: EdgeInsets.only(left: scaleF(14)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: List.generate(5, (index) {
                                  final starLevel = 5 - index;
                                  final count = reviews.where((r) => r.rating == starLevel).length;
                                  final double pct = reviews.isEmpty ? 0.0 : (count / reviews.length);
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: scaleF(1.5)),
                                    child: Row(
                                      children: [
                                        Text(
                                          '$starLevel',
                                          style: GoogleFonts.montserrat(
                                            fontSize: fs(10.5),
                                            fontWeight: FontWeight.bold,
                                            color: CustomersLoginThemeView.textDark,
                                          ),
                                        ),
                                        SizedBox(width: scaleF(4)),
                                        Icon(Icons.star, color: Colors.amber, size: scaleF(11)),
                                        SizedBox(width: scaleF(6)),
                                        Expanded(
                                          child: Container(
                                            height: scaleF(5),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(2.5),
                                            ),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: pct,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: CustomersLoginThemeView.primaryBlue,
                                                  borderRadius: BorderRadius.circular(2.5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: scaleF(20)),

                    // Reviews List
                    Text(
                      'All Customer Reviews (${reviews.length})',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.bold,
                        color: CustomersLoginThemeView.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(12)),

                    if (reviews.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: scaleF(40)),
                        child: Center(
                          child: Text(
                            'No reviews posted yet. Be the first to post one!',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              color: CustomersLoginThemeView.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    else
                      ...reviews.map((review) {
                        return Container(
                          margin: EdgeInsets.only(bottom: scaleF(12)),
                          padding: EdgeInsets.all(scaleF(14)),
                          decoration: CustomersLoginThemeView.cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: scaleF(38),
                                    height: scaleF(38),
                                    decoration: BoxDecoration(
                                      color: _getAvatarTint(review.userEmoji),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      review.userEmoji,
                                      style: TextStyle(fontSize: scaleF(18)),
                                    ),
                                  ),
                                  SizedBox(width: scaleF(12)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.userName,
                                          style: GoogleFonts.montserrat(
                                            fontSize: fs(13),
                                            fontWeight: FontWeight.bold,
                                            color: CustomersLoginThemeView.textDark,
                                          ),
                                        ),
                                        SizedBox(height: scaleF(2)),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(review.date),
                                          style: GoogleFonts.montserrat(
                                            fontSize: fs(10.5),
                                            color: CustomersLoginThemeView.textGrey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                                        color: Colors.amber,
                                        size: fs(16),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              SizedBox(height: scaleF(12)),
                              Text(
                                review.comment,
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(12),
                                  color: CustomersLoginThemeView.textDark,
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              // Bottom floating Action Bar to Post a Review
              Container(
                padding: EdgeInsets.fromLTRB(hPadding, scaleF(12), hPadding, scaleF(16) + MediaQuery.paddingOf(context).bottom),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => _showAddReviewBottomSheet(context, cart, scaleF, fs),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: scaleF(13)),
                    decoration: BoxDecoration(
                      color: CustomersLoginThemeView.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review_outlined, color: Colors.white, size: scaleF(18)),
                        SizedBox(width: scaleF(8)),
                        Text(
                          'Write a Product Review',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(13),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
