import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../home/views/bulk_booking_view.dart';
import '../../subscriptions/widgets/subscription_call_dialog.dart';

class ActiveBulkBookingView extends StatefulWidget {
  const ActiveBulkBookingView({super.key});

  @override
  State<ActiveBulkBookingView> createState() => _ActiveBulkBookingViewState();
}

class _ActiveBulkBookingViewState extends State<ActiveBulkBookingView> {
  static const _steps = [
    'Bulk order placed',
    'Preparing fresh dairy',
    'Out for delivery',
    'Delivered',
  ];

  int _activeStep = 1;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(minutes: 6), () {
      if (!mounted) return;
      setState(() => _activeStep = 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    final String paymentMethod = BulkBookingView.activePaymentMethod;
    final bool isCOD = paymentMethod == 'Cash on Delivery';

    return Scaffold(
      backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: CustomersLoginThemeView.primaryBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Bulk Booking Details',
          style: CustomersLoginThemeView.brandTitleStyle.copyWith(
            fontSize: fs(20),
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
        children: [


          // 1. Bulk Booking Button moved below AppBar (Styled in Primary Blue Theme)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomersLoginThemeView.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, scaleF(44)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.black, width: 1.0),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BulkBookingView(),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              'Book New Bulk Order',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: fs(14),
              ),
            ),
          ),
          SizedBox(height: scaleF(20)),

          // 2. Delivery Status Section Title
          Text(
            'Delivery Status',
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              color: CustomersLoginThemeView.sectionHeadingRed,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: scaleF(12)),

          // 3. Delivery Status Timeline Widget (identical to OrderTrackingView)
          Container(
            padding: EdgeInsets.all(scaleF(16)),
            decoration: CustomersLoginThemeView.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_steps.length, (i) => _stepTile(i, _activeStep, scaleF, fs)),
            ),
          ),
          SizedBox(height: scaleF(20)),

          // Placed Booking Details Section Title
          Text(
            'Order Summary',
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              color: CustomersLoginThemeView.sectionHeadingRed,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: scaleF(10)),

          // Details Card
          Container(
            padding: EdgeInsets.all(scaleF(16)),
            decoration: CustomersLoginThemeView.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bulk Booking ID
                _buildDetailRow(
                  label: 'Bulk Booking ID',
                  value: BulkBookingView.activeBulkBookingId,
                  isBoldValue: true,
                  valueColor: CustomersLoginThemeView.primaryBlue,
                  scaleF: scaleF,
                  fs: fs,
                ),
                _buildDivider(scaleF),

                // Product details row
                _buildDetailRow(
                  label: 'Selected Products',
                  value: 'Fresh Cow Milk (20 Litres)\nFresh Curd (10 Litres)\nFresh Buttermilk (10 Litres)',
                  scaleF: scaleF,
                  fs: fs,
                  isMultiline: true,
                ),
                _buildDivider(scaleF),

                // Booking Date & Time
                _buildDetailRow(
                  label: 'Booking Date & Time',
                  value: BulkBookingView.activeBookingDateTime,
                  scaleF: scaleF,
                  fs: fs,
                ),
                _buildDivider(scaleF),

                // Deposit amount OR payment status depending on COD/Online
                if (isCOD) ...[
                  _buildDetailRow(
                    label: 'Advance Deposit',
                    value: '₹500.00 Paid',
                    valueColor: const Color(0xFF2E7D32),
                    isBoldValue: true,
                    scaleF: scaleF,
                    fs: fs,
                  ),
                  _buildDivider(scaleF),
                ] else ...[
                  _buildDetailRow(
                    label: 'Payment Status',
                    value: 'Fully Paid (Online)',
                    valueColor: const Color(0xFF2E7D32),
                    isBoldValue: true,
                    scaleF: scaleF,
                    fs: fs,
                  ),
                  _buildDivider(scaleF),
                ],

                // Payment Method used
                _buildDetailRow(
                  label: 'Payment Option Done',
                  value: paymentMethod,
                  isBoldValue: true,
                  scaleF: scaleF,
                  fs: fs,
                ),
                _buildDivider(scaleF),

                // Status
                _buildDetailRow(
                  label: 'Delivery Status',
                  value: 'Pending Delivery',
                  valueColor: Colors.orange[800],
                  isBoldValue: true,
                  scaleF: scaleF,
                  fs: fs,
                ),
                _buildDivider(scaleF),

                // Address
                _buildDetailRow(
                  label: 'Delivery Address',
                  value: 'B-302, Green Meadows, Vadavalli, Coimbatore - 641041',
                  scaleF: scaleF,
                  fs: fs,
                  isMultiline: true,
                ),
                _buildDivider(scaleF),

                // Expected Date
                _buildDetailRow(
                  label: 'Estimated Delivery',
                  value: 'Tomorrow (Morning 5:00 AM - 9:00 AM)',
                  scaleF: scaleF,
                  fs: fs,
                ),
              ],
            ),
          ),
          SizedBox(height: scaleF(20)),

          // Help / Assistance card
          Container(
            padding: EdgeInsets.all(scaleF(16)),
            decoration: BoxDecoration(
              color: CustomersLoginThemeView.cardBackgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Need Help or Modifications?',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.bold,
                    color: CustomersLoginThemeView.textDark,
                  ),
                ),
                SizedBox(height: scaleF(6)),
                Text(
                  'Our logistics desk will contact you shortly to coordinate doorstep arrangements. For any doubts or immediate assistance, please call our help desk.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    color: CustomersLoginThemeView.textGrey,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: scaleF(16)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomersLoginThemeView.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, scaleF(44)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => showSubscriptionCallDialog(context),
                  icon: const Icon(Icons.call_rounded, color: Colors.white),
                  label: Text(
                    'Call Help Desk',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: fs(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepTile(int index, int active, double Function(double) scaleF, double Function(double) fs) {
    final done = index <= active;
    final isCurrent = index == active;
    return Padding(
      padding: EdgeInsets.only(bottom: scaleF(12)),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: scaleF(28),
            height: scaleF(28),
            decoration: BoxDecoration(
              color: done
                  ? CustomersLoginThemeView.primaryBlue
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: CustomersLoginThemeView.primaryBlue,
                width: 1.5,
              ),
            ),
            child: done
                ? Icon(Icons.check, size: scaleF(16), color: Colors.white)
                : null,
          ),
          SizedBox(width: scaleF(12)),
          Expanded(
            child: Text(
              _steps[index],
              style: GoogleFonts.montserrat(
                fontSize: fs(14),
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: done
                    ? CustomersLoginThemeView.primaryBlue
                    : CustomersLoginThemeView.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required double Function(double) scaleF,
    required double Function(double) fs,
    Color? valueColor,
    bool isBoldValue = false,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: scaleF(4)),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: fs(12),
                fontWeight: FontWeight.w600,
                color: CustomersLoginThemeView.textGrey,
              ),
            ),
          ),
          SizedBox(width: scaleF(12)),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                fontSize: fs(12),
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? CustomersLoginThemeView.textDark,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(double Function(double) scaleF) {
    return Divider(
      color: CustomersLoginThemeView.borderColor.withValues(alpha: 0.5),
      height: scaleF(20),
      thickness: 1,
    );
  }
}
