import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
class PaymentSuccessView extends StatefulWidget {
  final bool paidOnline;
  final VoidCallback onFinished;

  const PaymentSuccessView({
    super.key,
    required this.paidOnline,
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
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
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
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: CustomersLoginThemeView.primaryBlue
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CustomersLoginThemeView.primaryBlue,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 52,
                    color: CustomersLoginThemeView.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.paidOnline
                    ? 'Payment Successful'
                    : 'Order Placed Successfully',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: CustomersLoginThemeView.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.paidOnline
                    ? 'Order Confirmed'
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
