import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/services/haptic_service.dart';
class PaymentSuccessView extends StatefulWidget {
  final bool paidOnline;
  final bool isSubscription;
  final VoidCallback onFinished;

  const PaymentSuccessView({
    super.key,
    required this.paidOnline,
    this.isSubscription = false,
    required this.onFinished,
  });

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1, curve: Curves.easeOut),
    );
    _controller.forward();
    HapticService.success();
    Future<void>.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Lottie.asset(
                  'assets/animations/paymentsuccess.json',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.paidOnline
                    ? 'Payment Successful'
                    : (widget.isSubscription
                        ? 'Subscription Placed Successfully'
                        : 'Order Placed Successfully'),
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.paidOnline
                    ? (widget.isSubscription ? 'Subs Confirmed' : 'Order Confirmed')
                    : 'You can pay upon delivery',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CustomersLoginThemeView.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
