import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/customers_login_themeview.dart';
import '../../profile/viewmodels/customers_profile_viewmodel.dart';
import '../models/cart_models.dart';
import '../../payment/views/payment_selection_view.dart';
import '../viewmodels/cart_scope.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/cart_product_thumbnail.dart';

class DetailedBillView extends StatefulWidget {
  final CartViewModel cart;

  const DetailedBillView({super.key, required this.cart});

  @override
  State<DetailedBillView> createState() => _DetailedBillViewState();
}

class _DetailedBillViewState extends State<DetailedBillView> {
  late final DateTime _billDate;

  @override
  void initState() {
    super.initState();
    _billDate = DateTime.now();
  }

  void _proceedToPay() {
    if (widget.cart.items.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScope(
          store: widget.cart,
          child: const PaymentSelectionView(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    final dateStr = DateFormat('dd MMMM yyyy · hh:mm a').format(_billDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: CustomersLoginThemeView.primaryBlue,
        ),
        title: Text(
          'Detailed Bill',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                Text(
                  dateStr,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CustomersLoginThemeView.textGrey,
                  ),
                ),
                const SizedBox(height: 12),
                ...cart.items.map((item) => _BillItemTile(item: item)),
                const SizedBox(height: 12),
                const Divider(),
                _summaryRow('Items subtotal', cart.itemsSubtotalRupees),
                _summaryRow('Delivery charge', cart.deliveryChargeRupeesApplied),
                const SizedBox(height: 8),
                _summaryRow('To pay', cart.toPayRupees, bold: true),
                const Divider(height: 24, thickness: 1),
                BlocBuilder<CustomersProfileViewModel, CustomersProfileState>(
                  builder: (context, profileState) {
                    final model = profileState.model;
                    String displayAddress = 'Coimbatore (Primary)';
                    if (model.street.isNotEmpty) {
                      final parts = [
                        if (model.houseNo.isNotEmpty) model.houseNo,
                        if (model.apartmentName.isNotEmpty) model.apartmentName,
                        model.street,
                      ];
                      displayAddress = '${parts.join(', ')} (${model.deliveryPreference})';
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Address',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CustomersLoginThemeView.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text('📍', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  displayAddress,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: CustomersLoginThemeView.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _proceedToPay,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, int amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: bold ? 16 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: CustomersLoginThemeView.textDark,
            ),
          ),
          Text(
            '₹$amount',
            style: GoogleFonts.montserrat(
              fontSize: bold ? 18 : 13,
              fontWeight: FontWeight.w800,
              color: CustomersLoginThemeView.priceAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillItemTile extends StatelessWidget {
  final CartLineItem item;

  const _BillItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CartProductThumbnail(size: 56),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: CustomersLoginThemeView.textDark,
                  ),
                ),
                Text(
                  item.quantity,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CustomersLoginThemeView.quantityAccent,
                  ),
                ),
                Text(
                  'Qty: ${item.count}',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: CustomersLoginThemeView.textGrey,
                  ),
                ),
                Text(
                  'Milk ₹${item.milkPriceRupees}',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: CustomersLoginThemeView.textDark,
                  ),
                ),
                Text(
                  item.deliveryMethod.billLine,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CustomersLoginThemeView.quantityAccent,
                  ),
                ),
                if (item.hasDeposit)
                  Text(
                    'Deposit for glass bottle ₹${item.totalDepositRupees}',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: CustomersLoginThemeView.textGrey,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '₹${item.lineTotalRupees}',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: CustomersLoginThemeView.priceAccent,
            ),
          ),
        ],
      ),
    );
  }
}
