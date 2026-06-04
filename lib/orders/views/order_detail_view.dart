import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../models/daily_order_model.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../core/services/haptic_service.dart';
import '../../home/views/widgets/slide_to_act_button.dart';

class OrderDetailView extends StatefulWidget {
  final String orderId;

  const OrderDetailView({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  int _sliderKeyVal = 0;

  Color _paymentColor(String status) {
    switch (status) {
      case 'Paid':
        return PaalvandiTheme.statusSuccess;
      case 'Pay At Delivery':
        return PaalvandiTheme.statusWarning;
      default:
        return PaalvandiTheme.statusPending;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return PaalvandiTheme.deliveredGreen;
      case 'Accepted':
        return PaalvandiTheme.assignedBlue;
      case 'Cancelled':
        return PaalvandiTheme.statusError;
      case 'Assigned':
      default:
        return PaalvandiTheme.preparingAmber;
    }
  }

  String _getProductImageUrl(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('milk')) {
      return 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&q=80&w=200';
    } else if (lower.contains('curd')) {
      return 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&q=80&w=200';
    } else if (lower.contains('buttermilk') || lower.contains('butter')) {
      return 'https://images.unsplash.com/photo-1528498033973-3c07f7b4c26a?auto=format&fit=crop&q=80&w=200';
    }
    return 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&q=80&w=200';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Widget _buildFlowerBadge(String flower, Function scaleF, Function fs) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: scaleF(12), vertical: scaleF(6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: PaalvandiTheme.accentGreen,
            size: scaleF(14),
          ),
          SizedBox(width: scaleF(6)),
          Text(
            flower,
            style: GoogleFonts.montserrat(
              fontSize: fs(10),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _checkPaymentAndDeliver(
    BuildContext context,
    DailyOrderModel order,
    Function scaleF,
    Function fs,
    VoidCallback onReset,
  ) {
    final isCodOrQr = (order.paymentMethod == 'Cash on Delivery' ||
        order.paymentMethod == 'UPI' ||
        order.paymentStatus == 'Pay At Delivery');

    if (isCodOrQr && order.paymentStatus != 'Paid') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 1.5),
          ),
          child: Padding(
            padding: EdgeInsets.all(scaleF(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm Payment Collection',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w900,
                    fontSize: fs(16),
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: scaleF(12)),
                Text(
                  'Have you got the money for this order (₹${order.totalAmount.toStringAsFixed(0)})?',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: scaleF(24)),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticService.light();
                          Navigator.of(dialogCtx).pop(); // dismiss dialog
                          onReset(); // reset slider (come back automatically)
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'No',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: scaleF(12)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticService.light();
                          Navigator.of(dialogCtx).pop(); // dismiss dialog
                          _showOtpVerificationDialog(context, order, scaleF, fs); // move to OTP
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                          decoration: BoxDecoration(
                            color: PaalvandiTheme.statusSuccess,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'Yes, Got It',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      _showOtpVerificationDialog(context, order, scaleF, fs); // directly move to OTP
    }
  }

  void _showCancelOrderBottomSheet(
    BuildContext context,
    DailyOrderModel order,
    Function scaleF,
    Function fs,
  ) {
    HapticService.medium();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: PaalvandiTheme.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.all(scaleF(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cancel Order',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(18),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
                SizedBox(height: scaleF(16)),
                Text(
                  'Please provide a reason for cancelling this order:',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(12),
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
                SizedBox(height: scaleF(12)),
                TextField(
                  maxLines: 3,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter reason here...',
                    hintStyle: GoogleFonts.montserrat(
                      fontSize: fs(12),
                      color: PaalvandiTheme.textMuted,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PaalvandiTheme.cardBorder, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PaalvandiTheme.primaryBlue, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: scaleF(24)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PaalvandiTheme.statusError,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: scaleF(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      HapticService.heavy();
                      context.read<OrdersViewModel>().add(UpdateOrderStatus(order.orderId, 'Cancelled'));
                      Navigator.pop(bottomSheetContext);
                    },
                    child: Text(
                      'Confirm Cancellation',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.bold,
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
  }

  void _showStatusConfirmDialog(
    BuildContext context,
    DailyOrderModel order,
    String newStatus,
    String actionLabel,
    Color actionColor,
    Function scaleF,
    Function fs,
  ) {
    if (newStatus == 'Cancelled') {
      _showCancelOrderBottomSheet(context, order, scaleF, fs);
      return;
    }

    HapticService.medium();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: PaalvandiTheme.cardBorder, width: 2),
          ),
          backgroundColor: PaalvandiTheme.bgCream,
          child: Padding(
            padding: EdgeInsets.all(scaleF(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: scaleF(40),
                  color: actionColor,
                ),
                SizedBox(height: scaleF(16)),
                Text(
                  '$actionLabel this order?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(14),
                    fontWeight: FontWeight.bold,
                    color: PaalvandiTheme.textDark,
                  ),
                ),
                SizedBox(height: scaleF(8)),
                Text(
                  'Confirming will set the order status to Accepted.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(11),
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
                SizedBox(height: scaleF(24)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PaalvandiTheme.textDark,
                          side: const BorderSide(color: PaalvandiTheme.cardBorder, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: scaleF(10)),
                        ),
                        onPressed: () {
                          HapticService.light();
                          Navigator.pop(dialogContext);
                        },
                        child: Text(
                          'No',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: fs(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: scaleF(12)),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: scaleF(10)),
                        ),
                        onPressed: () {
                          HapticService.heavy();
                          context.read<OrdersViewModel>().add(UpdateOrderStatus(order.orderId, newStatus));
                          Navigator.pop(dialogContext);
                        },
                        child: Text(
                          'Yes, $actionLabel',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: fs(12),
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
      },
    );
  }

  void _showOtpVerificationDialog(BuildContext context, DailyOrderModel order, Function scaleF, Function fs) {
    final controller = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: PaalvandiTheme.cardBorder, width: 2),
              ),
              backgroundColor: PaalvandiTheme.bgCream,
              child: Padding(
                padding: EdgeInsets.all(scaleF(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_person_outlined,
                      size: scaleF(40),
                      color: PaalvandiTheme.primaryBlue,
                    ),
                    SizedBox(height: scaleF(16)),
                    Text(
                      'Enter Delivery OTP',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textDark,
                      ),
                    ),
                    SizedBox(height: scaleF(8)),
                    Text(
                      'Ask the customer for the 4-digit verification OTP (Hint: 4820).',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(11),
                        color: PaalvandiTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: scaleF(20)),
                    Container(
                      width: scaleF(130),
                      decoration: BoxDecoration(
                        border: Border.all(color: PaalvandiTheme.cardBorder, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                        color: PaalvandiTheme.cardWhite,
                      ),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(20),
                          letterSpacing: 8,
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.textDark,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0000',
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      SizedBox(height: scaleF(10)),
                      Text(
                        errorMessage!,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(11),
                          color: PaalvandiTheme.statusError,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    SizedBox(height: scaleF(24)),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: PaalvandiTheme.textDark,
                              side: const BorderSide(color: PaalvandiTheme.cardBorder, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.symmetric(vertical: scaleF(10)),
                            ),
                            onPressed: () {
                              HapticService.light();
                              Navigator.pop(dialogContext);
                            },
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: fs(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: scaleF(12)),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PaalvandiTheme.statusSuccess,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.symmetric(vertical: scaleF(10)),
                            ),
                            onPressed: () {
                              final pin = controller.text.trim();
                              if (pin == '4820') {
                                HapticService.heavy();
                                Navigator.pop(dialogContext);
                                context.read<OrdersViewModel>().add(MarkOrderDelivered(order.orderId));
                              } else {
                                HapticService.medium();
                                setDialogState(() {
                                  errorMessage = 'Invalid OTP. Try again!';
                                });
                              }
                            },
                            child: Text(
                              'Verify',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: fs(12),
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
          },
        );
      },
    );
  }

  void _showQrCodeDialog(BuildContext context, DailyOrderModel order, Function scaleF, Function fs) {
    HapticService.medium();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: PaalvandiTheme.cardBorder, width: 2),
          ),
          backgroundColor: PaalvandiTheme.cardWhite,
          child: Padding(
            padding: EdgeInsets.all(scaleF(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'UPI QR Payment',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: PaalvandiTheme.textMuted),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                SizedBox(height: scaleF(12)),
                // Mock QR Code Box
                Container(
                  padding: EdgeInsets.all(scaleF(16)),
                  decoration: BoxDecoration(
                    color: Colors.white, // Keep QR background white for high scanning contrast!
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.qr_code_2,
                    size: scaleF(180),
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: scaleF(16)),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(24),
                    fontWeight: FontWeight.w900,
                    color: PaalvandiTheme.textDark,
                  ),
                ),
                SizedBox(height: scaleF(4)),
                Text(
                  'Scan to pay via GPay, PhonePe or any UPI app',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(11),
                    color: PaalvandiTheme.textSecondary,
                  ),
                ),
                SizedBox(height: scaleF(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _upiLogo('BHIM', Colors.blue, scaleF, fs),
                    SizedBox(width: scaleF(12)),
                    _upiLogo('GPay', Colors.red, scaleF, fs),
                    SizedBox(width: scaleF(12)),
                    _upiLogo('PhonePe', Colors.purple, scaleF, fs),
                    SizedBox(width: scaleF(12)),
                    _upiLogo('Paytm', Colors.lightBlue, scaleF, fs),
                  ],
                ),
                SizedBox(height: scaleF(16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _upiLogo(String label, Color color, Function scaleF, Function fs) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: scaleF(8), vertical: scaleF(4)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: fs(9),
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleF =
        (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs =
        (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: PaalvandiTheme.bgCream,
      appBar: AppBar(
        backgroundColor: PaalvandiTheme.bgCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PaalvandiTheme.textDark),
          onPressed: () {
            HapticService.light();
            context.pop();
          },
        ),
        title: Text(
          'Order details',
          style: GoogleFonts.montserrat(
            fontSize: fs(18),
            fontWeight: FontWeight.bold,
            color: PaalvandiTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<OrdersViewModel, OrdersState>(
        listener: (context, state) {
          if (state.deliveredOrderId == widget.orderId) {
            HapticService.heavy();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Order ${widget.orderId} delivered successfully!',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: PaalvandiTheme.statusSuccess,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          final order = state.orders.firstWhere(
            (o) => o.orderId == widget.orderId,
            orElse: () => DailyOrderModel(
              orderId: widget.orderId,
              customerName: 'Customer',
              customerPhone: '',
              address: 'Address Not Found',
              products: const [],
              orderTime: DateTime.now(),
            ),
          );

          if (order.address == 'Address Not Found') {
            return Center(
              child: Text(
                'Order details not found.',
                style: GoogleFonts.montserrat(
                  fontSize: fs(14),
                  color: PaalvandiTheme.textSecondary,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Order Status Header Card
                Container(
                  padding: EdgeInsets.all(scaleF(16)),
                  decoration: PaalvandiTheme.cardDecoration.copyWith(
                    color: order.status == 'Accepted'
                        ? const Color(0xFFE8F5E9) // Light Green
                        : order.status == 'Cancelled' || order.status == 'Rejected'
                            ? const Color(0xFFFFEBEE) // Light Red
                            : order.status == 'Delivered'
                                ? const Color(0xFFE3F2FD) // Light Blue
                                : Colors.white, // New orders
                    border: Border.all(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderId,
                              style: GoogleFonts.montserrat(
                                fontSize: fs(16),
                                fontWeight: FontWeight.w900,
                                color: PaalvandiTheme.textDark,
                              ),
                            ),
                            SizedBox(height: scaleF(4)),
                            Text(
                              'Placed on ${order.orderTime.day.toString().padLeft(2, '0')}/${order.orderTime.month.toString().padLeft(2, '0')}/${order.orderTime.year} • Placed at ${_formatTime(order.orderTime)}',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(11),
                                color: PaalvandiTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: scaleF(8)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: scaleF(12),
                          vertical: scaleF(6),
                        ),
                        decoration: PaalvandiTheme.statusBadgeDecoration(
                          _statusColor(order.status),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: fs(10),
                            fontWeight: FontWeight.bold,
                            color: _statusColor(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleF(16)),

                // 2. Customer & Delivery Address Card
                Container(
                  padding: EdgeInsets.all(scaleF(16)),
                  decoration: PaalvandiTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery details',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(14),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(12)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(scaleF(8)),
                            decoration: BoxDecoration(
                              color: PaalvandiTheme.primaryBlue.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_outline,
                              color: PaalvandiTheme.primaryBlue,
                              size: scaleF(20),
                            ),
                          ),
                          SizedBox(width: scaleF(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.customerName,
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(13),
                                    fontWeight: FontWeight.bold,
                                    color: PaalvandiTheme.textDark,
                                  ),
                                ),
                                SizedBox(height: scaleF(2)),
                                Text(
                                  '+91 ${order.customerPhone}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(12),
                                    color: PaalvandiTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: scaleF(16)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(scaleF(8)),
                            decoration: BoxDecoration(
                              color: PaalvandiTheme.primaryBlue.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: PaalvandiTheme.primaryBlue,
                              size: scaleF(20),
                            ),
                          ),
                          SizedBox(width: scaleF(12)),
                          Expanded(
                            child: Text(
                              order.address,
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                height: 1.4,
                                color: PaalvandiTheme.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (order.status == 'Assigned' || order.status == 'Accepted') ...[
                        SizedBox(height: scaleF(16)),
                        Divider(color: PaalvandiTheme.dividerColor, height: 1),
                        SizedBox(height: scaleF(12)),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.phone_outlined, size: 18),
                                label: const Text('Call Customer'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: PaalvandiTheme.accentGreen,
                                  side: const BorderSide(color: PaalvandiTheme.accentGreen),
                                  padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  HapticService.light();
                                  final uri = Uri.parse('tel:${order.customerPhone}');
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                },
                              ),
                            ),
                            SizedBox(width: scaleF(12)),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.navigation_outlined, size: 18),
                                label: const Text('Navigate'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PaalvandiTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  HapticService.light();
                                  final encoded = Uri.encodeComponent(order.address);
                                  launchUrl(
                                    Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded'),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: scaleF(16)),

                // 3. Products details & Amount Card
                Container(
                  padding: EdgeInsets.all(scaleF(16)),
                  decoration: PaalvandiTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Items ordered',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(14),
                          fontWeight: FontWeight.bold,
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(12)),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.products.length,
                        separatorBuilder: (_, __) => Padding(
                          padding: EdgeInsets.symmetric(vertical: scaleF(8)),
                          child: Divider(color: PaalvandiTheme.dividerColor, height: 1),
                        ),
                        itemBuilder: (context, idx) {
                          final prod = order.products[idx];
                          return Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _getProductImageUrl(prod.name),
                                  width: scaleF(48),
                                  height: scaleF(48),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: scaleF(48),
                                    height: scaleF(48),
                                    color: PaalvandiTheme.primaryBlue.withOpacity(0.08),
                                    child: Icon(
                                      Icons.local_drink_outlined,
                                      color: PaalvandiTheme.primaryBlue,
                                      size: scaleF(24),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: scaleF(12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prod.name,
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(13),
                                        fontWeight: FontWeight.bold,
                                        color: PaalvandiTheme.textDark,
                                      ),
                                    ),
                                    SizedBox(height: scaleF(2)),
                                    Text(
                                      'Unit: ${prod.unit}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(11),
                                        color: PaalvandiTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '× ${prod.quantity}',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(14),
                                  fontWeight: FontWeight.w800,
                                  color: PaalvandiTheme.textDark,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: scaleF(16)),
                      Divider(color: PaalvandiTheme.cardBorder, thickness: 1),
                      SizedBox(height: scaleF(12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Product Total (Real Milk Amount)',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              color: PaalvandiTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '₹${(order.totalAmount - order.bottleDepositAmount).toStringAsFixed(0)}',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              fontWeight: FontWeight.w600,
                              color: PaalvandiTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      if (order.bottleDepositAmount > 0) ...[
                        SizedBox(height: scaleF(8)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bottle Deposit Amount',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                color: PaalvandiTheme.textSecondary,
                              ),
                            ),
                            Text(
                              '₹${order.bottleDepositAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                fontWeight: FontWeight.w600,
                                color: PaalvandiTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: scaleF(8)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery Fee',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              color: PaalvandiTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'FREE',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              fontWeight: FontWeight.bold,
                              color: PaalvandiTheme.accentGreen,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: scaleF(12)),
                      Divider(color: PaalvandiTheme.dividerColor, height: 1),
                      SizedBox(height: scaleF(12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(14),
                              fontWeight: FontWeight.bold,
                              color: PaalvandiTheme.textDark,
                            ),
                          ),
                          Text(
                            '₹${order.totalAmount.toStringAsFixed(0)}',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(18),
                              fontWeight: FontWeight.w900,
                              color: PaalvandiTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleF(16)),

                // 4. Payment Info Card
                Container(
                  padding: EdgeInsets.all(scaleF(16)),
                  decoration: PaalvandiTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payment_outlined,
                                color: PaalvandiTheme.primaryBlue,
                                size: scaleF(20),
                              ),
                              SizedBox(width: scaleF(12)),
                              Text(
                                'Payment details',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(14),
                                  fontWeight: FontWeight.bold,
                                  color: PaalvandiTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: scaleF(8),
                              vertical: scaleF(4),
                            ),
                            decoration: PaalvandiTheme.statusBadgeDecoration(
                              _paymentColor(order.paymentStatus),
                            ),
                            child: Text(
                              order.paymentStatus.toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: fs(10),
                                fontWeight: FontWeight.bold,
                                color: _paymentColor(order.paymentStatus),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: scaleF(12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment Method',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              color: PaalvandiTheme.textSecondary,
                            ),
                          ),
                          Text(
                            order.paymentMethod,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              fontWeight: FontWeight.bold,
                              color: PaalvandiTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: scaleF(6)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transaction Status',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              color: PaalvandiTheme.textSecondary,
                            ),
                          ),
                          Text(
                            order.paymentStatus == 'Paid' ? 'Success (Auto-settled)' : 'Pending Handover',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              fontWeight: FontWeight.w600,
                              color: order.paymentStatus == 'Paid'
                                  ? PaalvandiTheme.accentGreen
                                  : PaalvandiTheme.statusWarning,
                            ),
                          ),
                        ],
                      ),
                      if (order.paymentStatus == 'Pay At Delivery') ...[
                        SizedBox(height: scaleF(12)),
                        Divider(color: PaalvandiTheme.dividerColor, height: 1),
                        SizedBox(height: scaleF(12)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Collection Options',
                              style: GoogleFonts.montserrat(
                                fontSize: fs(12),
                                color: PaalvandiTheme.textSecondary,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Hand Cash  or  ',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(11),
                                    fontWeight: FontWeight.bold,
                                    color: PaalvandiTheme.accentGreen,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.qr_code_2_outlined, size: 16),
                                  label: const Text('Show QR'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: PaalvandiTheme.primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: scaleF(12),
                                      vertical: scaleF(6),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => _showQrCodeDialog(context, order, scaleF, fs),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: scaleF(16)),

                // 5. 🎉 6th Milestone Delivery Reward Card (Only if 6th delivery for same person)
                if (order.orderId == 'PV-7842' || order.customerName == 'Nandha Prabhu') ...[
                  Container(
                    padding: EdgeInsets.all(scaleF(16)),
                    decoration: PaalvandiTheme.cardDecoration.copyWith(
                      color: const Color(0xFFF0FDF4), // Soft green background
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              color: PaalvandiTheme.statusWarning,
                              size: scaleF(24),
                            ),
                            SizedBox(width: scaleF(8)),
                            Expanded(
                              child: Text(
                                '🎉 6th Milestone Delivery Reward!',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(14),
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF166534), // Dark green text
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: scaleF(12)),
                        Text(
                          'This customer is placing their 6th order! Delivery partner needs to deliver any four flowers selected by the user below:',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(11),
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: scaleF(16)),
                        Wrap(
                          spacing: scaleF(8),
                          runSpacing: scaleF(8),
                          children: [
                            _buildFlowerBadge('🌹 Red Rose', scaleF, fs),
                            _buildFlowerBadge('🪷 Sacred Lotus', scaleF, fs),
                            _buildFlowerBadge('🌻 Sunflower', scaleF, fs),
                            _buildFlowerBadge('🌸 Jasmine', scaleF, fs),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: scaleF(16)),
                ],

                // 6. Action button section based on status
                if (order.status == 'Assigned') ...[
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showStatusConfirmDialog(
                            context,
                            order,
                            'Cancelled',
                            'Cancel',
                            PaalvandiTheme.statusError,
                            scaleF,
                            fs,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: scaleF(14)),
                            decoration: BoxDecoration(
                              color: PaalvandiTheme.statusError,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel_outlined, color: Colors.white, size: scaleF(16)),
                                SizedBox(width: scaleF(6)),
                                Text(
                                  'Cancel Order',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(11),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: scaleF(12)),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final hasActiveAccepted = state.orders.any((o) => o.status == 'Accepted');
                            if (hasActiveAccepted) {
                              HapticService.heavy();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'You can only accept one order at a time. Please complete or cancel your current active order first!',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: PaalvandiTheme.statusError,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            } else {
                              _showStatusConfirmDialog(
                                context,
                                order,
                                'Accepted',
                                'Accept',
                                PaalvandiTheme.accentGreen,
                                scaleF,
                                fs,
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: scaleF(14)),
                            decoration: BoxDecoration(
                              color: PaalvandiTheme.accentGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.white, size: scaleF(16)),
                                SizedBox(width: scaleF(6)),
                                Text(
                                  'Accept Order',
                                  style: GoogleFonts.montserrat(
                                    fontSize: fs(11),
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
                ] else if (order.status == 'Accepted') ...[
                  SlideToActButton(
                    key: ValueKey(_sliderKeyVal),
                    text: 'Slide to confirm delivery',
                    onSubmitted: () {
                      HapticService.medium();
                      _checkPaymentAndDeliver(
                        context,
                        order,
                        scaleF,
                        fs,
                        () {
                          setState(() {
                            _sliderKeyVal++; // Force reset slider position!
                          });
                        },
                      );
                    },
                    sliderColor: PaalvandiTheme.statusSuccess,
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: scaleF(16)),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _statusColor(order.status).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          order.status == 'Delivered' ? Icons.check_circle : Icons.cancel,
                          color: _statusColor(order.status),
                          size: scaleF(28),
                        ),
                        SizedBox(height: scaleF(6)),
                        Text(
                          order.status == 'Delivered' ? 'Order Delivered' : 'Order Cancelled',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(13),
                            fontWeight: FontWeight.bold,
                            color: _statusColor(order.status),
                          ),
                        ),
                        SizedBox(height: scaleF(4)),
                        Text(
                          'This order is in a read-only state.',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(10),
                            color: PaalvandiTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: scaleF(24)),
              ],
            ),
          );
        },
      ),
    );
  }
}
