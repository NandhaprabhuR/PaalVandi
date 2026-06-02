import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/delivery_order_model.dart';
import '../viewmodels/delivery_home_viewmodel.dart';
import '../views/widgets/slide_to_act_button.dart';
import '../../theme/delivery_theme.dart';
import '../../core/widgets/responsive_helper.dart';

class DeliveryOrderDetailView extends StatefulWidget {
  const DeliveryOrderDetailView({super.key});

  @override
  State<DeliveryOrderDetailView> createState() => _DeliveryOrderDetailViewState();
}

class _DeliveryOrderDetailViewState extends State<DeliveryOrderDetailView> {
  final TextEditingController _otpVerifyController = TextEditingController();
  bool _showOtpField = false;

  @override
  void dispose() {
    _otpVerifyController.dispose();
    super.dispose();
  }

  void _handleStatusTransition(BuildContext context, DeliveryOrderModel active) {
    final bloc = context.read<DeliveryHomeViewModel>();
    if (active.deliveryStatus == 'Accepted') {
      bloc.add(UpdateDeliveryStatus(active.orderId, 'Arrived'));
    } else if (active.deliveryStatus == 'Arrived') {
      bloc.add(UpdateDeliveryStatus(active.orderId, 'Dispatched'));
    } else if (active.deliveryStatus == 'Dispatched') {
      setState(() {
        _showOtpField = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs = (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return BlocConsumer<DeliveryHomeViewModel, DeliveryHomeState>(
      listener: (context, state) {
        if (state.deliveryCompleteSuccess) {
          // Play complete successfully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Order delivered successfully! Earnings updated.',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white),
              ),
              backgroundColor: DeliveryTheme.statusOnline,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.go('/home');
        }
      },
      builder: (context, state) {
        final active = state.activeOrder;

        if (active == null) {
          return Scaffold(
            backgroundColor: DeliveryTheme.bgDark,
            appBar: AppBar(title: const Text('Trip Details')),
            body: Center(
              child: Text(
                'No active delivery trip found.',
                style: GoogleFonts.montserrat(fontSize: fs(14), color: DeliveryTheme.textSecondary),
              ),
            ),
          );
        }

        String slideText = 'Slide to Arrive at Hub';
        if (active.deliveryStatus == 'Arrived') {
          slideText = 'Slide to Start Delivery';
        } else if (active.deliveryStatus == 'Dispatched') {
          slideText = 'Slide to Deliver Order';
        }

        return Scaffold(
          backgroundColor: DeliveryTheme.bgDark,
          appBar: AppBar(
            backgroundColor: DeliveryTheme.bgDark,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/home'),
            ),
            title: Text(
              'Trip ${active.orderId}',
              style: GoogleFonts.montserrat(
                fontSize: fs(18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Delivery Timeline Progress Card
                  _buildTimelineProgressCard(active, fs, scaleF),
                  SizedBox(height: scaleF(24)),

                  // 2. Map representation / Delivery details
                  _buildMockMapCard(active, fs, scaleF),
                  SizedBox(height: scaleF(24)),

                  // 3. Customer & Address Details Card
                  _buildCustomerDetailsCard(active, fs, scaleF),
                  SizedBox(height: scaleF(24)),

                  // 4. Product items detail summary list
                  _buildItemsCard(active, fs, scaleF),
                  SizedBox(height: scaleF(24)),

                  // 5. Payment details card
                  _buildPaymentBreakdownCard(active, fs, scaleF),
                  SizedBox(height: scaleF(32)),

                  // 6. Interactive status slide slider (GPay style)
                  if (!_showOtpField)
                    SlideToActButton(
                      text: slideText,
                      onSubmitted: () => _handleStatusTransition(context, active),
                    )
                  else ...[
                    // OTP Verification input field
                    _buildOtpVerificationWidget(context, active, fs, scaleF, state.otpError),
                  ],
                  SizedBox(height: scaleF(40)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineProgressCard(DeliveryOrderModel active, Function fs, Function scaleF) {
    final status = active.deliveryStatus;

    bool isAccepted = true;
    bool isArrived = status == 'Arrived' || status == 'Dispatched' || status == 'Delivered';
    bool isDispatched = status == 'Dispatched' || status == 'Delivered';
    bool isDelivered = status == 'Delivered';

    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Timeline',
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              color: DeliveryTheme.textLight,
            ),
          ),
          SizedBox(height: scaleF(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineStep('Accepted', isAccepted, fs, scaleF),
              _buildTimelineLine(isArrived, scaleF),
              _buildTimelineStep('At Hub', isArrived, fs, scaleF),
              _buildTimelineLine(isDispatched, scaleF),
              _buildTimelineStep('Dispatched', isDispatched, fs, scaleF),
              _buildTimelineLine(isDelivered, scaleF),
              _buildTimelineStep('Delivered', isDelivered, fs, scaleF),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, bool isActive, Function fs, Function scaleF) {
    return Column(
      children: [
        Container(
          width: scaleF(14),
          height: scaleF(14),
          decoration: BoxDecoration(
            color: isActive ? DeliveryTheme.primaryOrange : DeliveryTheme.borderDark,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [BoxShadow(color: DeliveryTheme.primaryOrange.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)]
                : [],
          ),
        ),
        SizedBox(height: scaleF(8)),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: fs(10),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? DeliveryTheme.textLight : DeliveryTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isActive, Function scaleF) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? DeliveryTheme.primaryOrange : DeliveryTheme.borderDark,
        margin: EdgeInsets.only(bottom: scaleF(18)),
      ),
    );
  }

  Widget _buildMockMapCard(DeliveryOrderModel active, Function fs, Function scaleF) {
    String message = 'Go to Coimbatore Hub to pick up dairy bags.';
    if (active.deliveryStatus == 'Arrived') {
      message = 'Pick up cow milk/curds from Hub manager.';
    } else if (active.deliveryStatus == 'Dispatched') {
      message = 'Proceed to ${active.customerName}\'s delivery location.';
    }

    return Container(
      height: scaleF(120),
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Graphic abstract placeholder for maps
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/background_images/login_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(scaleF(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ESTIMATED TRAVEL',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(10),
                        fontWeight: FontWeight.bold,
                        color: DeliveryTheme.primaryOrange,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '12 mins • 3.2 km',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(12),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.directions_bike, color: DeliveryTheme.primaryOrange, size: scaleF(20)),
                    SizedBox(width: scaleF(12)),
                    Expanded(
                      child: Text(
                        message,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          fontWeight: FontWeight.w600,
                          color: DeliveryTheme.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsCard(DeliveryOrderModel active, Function fs, Function scaleF) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Details',
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              color: DeliveryTheme.textLight,
            ),
          ),
          SizedBox(height: scaleF(16)),
          Row(
            children: [
              Icon(Icons.person, color: DeliveryTheme.primaryOrange, size: scaleF(20)),
              SizedBox(width: scaleF(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    active.customerName,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: DeliveryTheme.textLight,
                    ),
                  ),
                  Text(
                    '+91 ${active.customerPhone}',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(12),
                      color: DeliveryTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: scaleF(16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: DeliveryTheme.primaryOrange, size: scaleF(20)),
              SizedBox(width: scaleF(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      active.address,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(13),
                        fontWeight: FontWeight.bold,
                        color: DeliveryTheme.textLight,
                        height: 1.3,
                      ),
                    ),
                    if (active.landmark.isNotEmpty) ...[
                      SizedBox(height: scaleF(4)),
                      Text(
                        'Landmark: ${active.landmark}',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(11),
                          color: DeliveryTheme.accentAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(DeliveryOrderModel active, Function fs, Function scaleF) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items List (${active.items.length})',
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              color: DeliveryTheme.textLight,
            ),
          ),
          SizedBox(height: scaleF(12)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: active.items.length,
            separatorBuilder: (c, idx) => Divider(color: DeliveryTheme.borderDark, height: scaleF(16)),
            itemBuilder: (context, index) {
              final item = active.items[index];
              final isCurd = item.productName.toLowerCase().contains('curd');

              return Row(
                children: [
                  // Dynamic thumbnail mapping matching GPay colors/style
                  Container(
                    width: scaleF(40),
                    height: scaleF(40),
                    decoration: BoxDecoration(
                      color: DeliveryTheme.borderDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      isCurd ? 'assets/100mlbottle.png' : 'assets/allbottles.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: scaleF(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: GoogleFonts.montserrat(
                            fontSize: fs(13),
                            fontWeight: FontWeight.bold,
                            color: DeliveryTheme.textLight,
                          ),
                        ),
                        Text(
                          'Qty: ${item.quantity}',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            color: DeliveryTheme.textSecondary,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildPaymentBreakdownCard(DeliveryOrderModel active, Function fs, Function scaleF) {
    final balanceToCollect = active.totalAmount - active.advancePaid;

    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Breakdown',
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              color: DeliveryTheme.textLight,
            ),
          ),
          SizedBox(height: scaleF(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Bill Amount',
                style: GoogleFonts.montserrat(fontSize: fs(12), color: DeliveryTheme.textSecondary),
              ),
              Text(
                '₹${active.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(fontSize: fs(13), fontWeight: FontWeight.bold, color: DeliveryTheme.textLight),
              ),
            ],
          ),
          SizedBox(height: scaleF(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advance Paid Online',
                style: GoogleFonts.montserrat(fontSize: fs(12), color: DeliveryTheme.textSecondary),
              ),
              Text(
                '- ₹${active.advancePaid.toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(fontSize: fs(13), fontWeight: FontWeight.bold, color: DeliveryTheme.statusOnline),
              ),
            ],
          ),
          Divider(color: DeliveryTheme.borderDark, height: scaleF(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collect Cash (COD)',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(13),
                      fontWeight: FontWeight.bold,
                      color: DeliveryTheme.textLight,
                    ),
                  ),
                  Text(
                    active.isCod ? 'Cash on Delivery selected' : 'Fully Paid Online',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(10),
                      color: DeliveryTheme.textMuted,
                    ),
                  ),
                ],
              ),
              Text(
                active.isCod ? '₹${balanceToCollect.toStringAsFixed(2)}' : '₹0.00',
                style: GoogleFonts.montserrat(
                  fontSize: fs(18),
                  fontWeight: FontWeight.w900,
                  color: active.isCod ? DeliveryTheme.accentAmber : DeliveryTheme.statusOnline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerificationWidget(BuildContext context, DeliveryOrderModel active, Function fs, Function scaleF, bool hasError) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DeliveryTheme.primaryOrange.withOpacity(0.5), width: 1.5),
      ),
      padding: EdgeInsets.all(scaleF(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Confirm Delivery OTP',
            style: GoogleFonts.montserrat(
              fontSize: fs(14),
              fontWeight: FontWeight.bold,
              color: DeliveryTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: scaleF(4)),
          Text(
            'Enter the 6-digit code provided by ${active.customerName} to finalize.',
            style: GoogleFonts.montserrat(
              fontSize: fs(11),
              color: DeliveryTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: scaleF(20)),
          TextField(
            controller: _otpVerifyController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: fs(18),
              letterSpacing: 8,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: GoogleFonts.montserrat(letterSpacing: 8, color: DeliveryTheme.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DeliveryTheme.borderDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DeliveryTheme.primaryOrange),
              ),
              counterText: '',
              fillColor: DeliveryTheme.bgDark,
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: scaleF(12)),
            ),
          ),
          if (hasError) ...[
            SizedBox(height: scaleF(8)),
            Text(
              'Incorrect OTP. Please enter the correct code (e.g. 123456)',
              style: GoogleFonts.montserrat(
                fontSize: fs(11),
                color: DeliveryTheme.statusOffline,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: scaleF(20)),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showOtpField = false;
                      _otpVerifyController.clear();
                    });
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(12),
                      fontWeight: FontWeight.bold,
                      color: DeliveryTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: scaleF(12)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<DeliveryHomeViewModel>().add(
                          VerifyOtpAndDeliver(active.orderId, _otpVerifyController.text),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DeliveryTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Verify & Complete',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
