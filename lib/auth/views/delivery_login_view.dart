import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/delivery_auth_viewmodel.dart';
import '../../theme/delivery_theme.dart';
import '../../core/widgets/responsive_helper.dart';

class DeliveryLoginView extends StatefulWidget {
  const DeliveryLoginView({super.key});

  @override
  State<DeliveryLoginView> createState() => _DeliveryLoginViewState();
}

class _DeliveryLoginViewState extends State<DeliveryLoginView> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  int _timerSeconds = 60;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 60;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs = (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: DeliveryTheme.bgDark,
      body: BlocConsumer<DeliveryAuthViewModel, DeliveryAuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go('/home');
          } else if (state is AuthCodeSent) {
            _startTimer();
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white),
                ),
                backgroundColor: DeliveryTheme.primaryOrange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isOtpStep = state is AuthCodeSent || (state is AuthLoading && _otpController.text.isNotEmpty);
          final isLoading = state is AuthLoading;

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: scaleF(40)),
                    // Vibrant Deliveryman Lottie
                    Center(
                      child: Lottie.asset(
                        'assets/animations/On time Delivery.json',
                        height: scaleF(180),
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: scaleF(24)),

                    // Brand & Title
                    Text(
                      'PaalVandi Partners',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(26),
                        fontWeight: FontWeight.w900,
                        color: DeliveryTheme.primaryOrange,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: scaleF(8)),
                    Text(
                      isOtpStep 
                        ? 'Enter the 6-digit code sent to +91 ${_phoneController.text}'
                        : 'Deliver fresh milk and curd daily. Earn on every single trip.',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(13),
                        fontWeight: FontWeight.w500,
                        color: DeliveryTheme.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: scaleF(40)),

                    if (!isOtpStep) ...[
                      // Phone Input
                      Text(
                        'Mobile Number',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          fontWeight: FontWeight.bold,
                          color: DeliveryTheme.textLight,
                        ),
                      ),
                      SizedBox(height: scaleF(8)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                          color: DeliveryTheme.cardDark,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: scaleF(16)),
                              child: Text(
                                '+91',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(16),
                                  fontWeight: FontWeight.bold,
                                  color: DeliveryTheme.textLight,
                                ),
                              ),
                            ),
                            Container(
                              height: scaleF(24),
                              width: 1.5,
                              color: DeliveryTheme.borderDark,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(16),
                                  fontWeight: FontWeight.bold,
                                  color: DeliveryTheme.textLight,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter 10-digit number',
                                  hintStyle: GoogleFonts.montserrat(
                                    fontSize: fs(14),
                                    color: DeliveryTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(16)),
                                ),
                                onChanged: (val) => context.read<DeliveryAuthViewModel>().add(AuthPhoneChanged(val)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: scaleF(32)),

                      // Submit Phone Button
                      SizedBox(
                        height: scaleF(52),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () {
                            FocusScope.of(context).unfocus();
                            context.read<DeliveryAuthViewModel>().add(const AuthPhoneSubmitted());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DeliveryTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Send OTP Code',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(15),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                    ] else ...[
                      // OTP Input
                      Text(
                        'Enter 6-Digit OTP',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(12),
                          fontWeight: FontWeight.bold,
                          color: DeliveryTheme.textLight,
                        ),
                      ),
                      SizedBox(height: scaleF(8)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: DeliveryTheme.primaryOrange.withOpacity(0.5), width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                          color: DeliveryTheme.cardDark,
                        ),
                        child: TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: fs(18),
                            letterSpacing: 10,
                            color: DeliveryTheme.textLight,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '000000',
                            hintStyle: GoogleFonts.montserrat(letterSpacing: 10, fontSize: fs(18), color: DeliveryTheme.textMuted),
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(vertical: scaleF(16)),
                          ),
                          onChanged: (val) => context.read<DeliveryAuthViewModel>().add(AuthOtpChanged(val)),
                        ),
                      ),
                      SizedBox(height: scaleF(20)),

                      // Countdown & Resend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _timerSeconds > 0 ? 'Resend in ${_timerSeconds}s' : 'Didn\'t receive OTP?',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              fontWeight: FontWeight.w500,
                              color: DeliveryTheme.textSecondary,
                            ),
                          ),
                          if (_timerSeconds == 0)
                            GestureDetector(
                              onTap: () {
                                _startTimer();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'OTP code resent successfully.',
                                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                    backgroundColor: DeliveryTheme.primaryOrange,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              child: Text(
                                'Resend OTP',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(12),
                                  fontWeight: FontWeight.bold,
                                  color: DeliveryTheme.primaryOrange,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: scaleF(32)),

                      // Verify OTP Button
                      SizedBox(
                        height: scaleF(52),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () {
                            FocusScope.of(context).unfocus();
                            context.read<DeliveryAuthViewModel>().add(const AuthOtpSubmitted());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DeliveryTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Verify & Start Duty',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(15),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                      SizedBox(height: scaleF(16)),

                      // Back Button to change phone
                      TextButton(
                        onPressed: isLoading ? null : () {
                          _otpController.clear();
                          context.read<DeliveryAuthViewModel>().add(AuthPhoneChanged(_phoneController.text));
                        },
                        child: Text(
                          'Change Mobile Number',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: FontWeight.bold,
                            color: DeliveryTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
