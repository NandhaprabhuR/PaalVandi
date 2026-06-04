import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../theme/paalvandi_theme.dart';
import '../../core/widgets/responsive_helper.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
    setState(() => _timerSeconds = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _timerSeconds--);
      }
    });
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
      body: BlocConsumer<AuthViewModel, AuthState>(
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
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600, color: Colors.white),
                ),
                backgroundColor: PaalvandiTheme.statusError,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          // Access Denied state
          if (state is AuthAccessDenied) {
            return _buildAccessDeniedScreen(context, scaleF, fs, hPadding);
          }

          final isOtpStep = state is AuthCodeSent ||
              (state is AuthLoading && _otpController.text.isNotEmpty);
          final isLoading = state is AuthLoading;

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                    horizontal: hPadding, vertical: scaleF(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: scaleF(40)),
                    // Lottie Animation
                    Center(
                      child: Lottie.asset(
                        'assets/animations/On time Delivery.json',
                        height: scaleF(180),
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: scaleF(24)),

                    // Brand Title
                    Text(
                      'PaalVandi Partners',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(26),
                        fontWeight: FontWeight.w900,
                        color: PaalvandiTheme.primaryBlue,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: scaleF(8)),
                    Text(
                      isOtpStep
                          ? 'Enter the 6-digit code sent to +91 ${_phoneController.text}'
                          : 'Deliver fresh milk and curd daily.\nEarn on every single trip.',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(13),
                        fontWeight: FontWeight.w500,
                        color: PaalvandiTheme.textSecondary,
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
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(8)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: PaalvandiTheme.cardBorder, width: 1),
                          borderRadius: BorderRadius.circular(12),
                          color: PaalvandiTheme.cardWhite,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: scaleF(16)),
                              child: Text(
                                '+91',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(16),
                                  fontWeight: FontWeight.bold,
                                  color: PaalvandiTheme.textDark,
                                ),
                              ),
                            ),
                            Container(
                              height: scaleF(24),
                              width: 1,
                              color: PaalvandiTheme.cardBorderLight,
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
                                  color: PaalvandiTheme.textDark,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter 10-digit number',
                                  hintStyle: GoogleFonts.montserrat(
                                    fontSize: fs(14),
                                    color: PaalvandiTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: scaleF(16),
                                      vertical: scaleF(16)),
                                ),
                                onChanged: (val) => context
                                    .read<AuthViewModel>()
                                    .add(AuthPhoneChanged(val)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: scaleF(32)),

                      // Send OTP Button
                      SizedBox(
                        height: scaleF(52),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  context
                                      .read<AuthViewModel>()
                                      .add(const AuthPhoneSubmitted());
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PaalvandiTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
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
                          color: PaalvandiTheme.textDark,
                        ),
                      ),
                      SizedBox(height: scaleF(8)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  PaalvandiTheme.primaryBlue.withOpacity(0.5),
                              width: 1),
                          borderRadius: BorderRadius.circular(12),
                          color: PaalvandiTheme.cardWhite,
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
                            color: PaalvandiTheme.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '000000',
                            hintStyle: GoogleFonts.montserrat(
                                letterSpacing: 10,
                                fontSize: fs(18),
                                color: PaalvandiTheme.textMuted),
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: scaleF(16)),
                          ),
                          onChanged: (val) => context
                              .read<AuthViewModel>()
                              .add(AuthOtpChanged(val)),
                        ),
                      ),
                      SizedBox(height: scaleF(20)),

                      // Timer & Resend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _timerSeconds > 0
                                ? 'Resend in ${_timerSeconds}s'
                                : 'Didn\'t receive OTP?',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              fontWeight: FontWeight.w500,
                              color: PaalvandiTheme.textSecondary,
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
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    backgroundColor:
                                        PaalvandiTheme.statusSuccess,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              child: Text(
                                'Resend OTP',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(12),
                                  fontWeight: FontWeight.bold,
                                  color: PaalvandiTheme.primaryBlue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: scaleF(32)),

                      // Verify Button
                      SizedBox(
                        height: scaleF(52),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  context
                                      .read<AuthViewModel>()
                                      .add(const AuthOtpSubmitted());
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PaalvandiTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
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

                      // Change Number
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                _otpController.clear();
                                context.read<AuthViewModel>().add(
                                    AuthPhoneChanged(_phoneController.text));
                              },
                        child: Text(
                          'Change Mobile Number',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(12),
                            fontWeight: FontWeight.bold,
                            color: PaalvandiTheme.textSecondary,
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

  Widget _buildAccessDeniedScreen(
      BuildContext context, Function scaleF, Function fs, double hPadding) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Lottie.asset(
                'assets/animations/Accountdelete.json',
                height: scaleF(160),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: scaleF(32)),
            Container(
              padding: EdgeInsets.all(scaleF(24)),
              decoration: PaalvandiTheme.cardDecoration,
              child: Column(
                children: [
                  Icon(Icons.block_rounded,
                      color: PaalvandiTheme.statusError, size: scaleF(48)),
                  SizedBox(height: scaleF(16)),
                  Text(
                    'Access Denied',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(22),
                      fontWeight: FontWeight.w900,
                      color: PaalvandiTheme.statusError,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: scaleF(12)),
                  Text(
                    'Your phone number is not approved for delivery operations. Please contact PaalVandi Admin to get access.',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(13),
                      fontWeight: FontWeight.w500,
                      color: PaalvandiTheme.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: scaleF(24)),
                  SizedBox(
                    width: double.infinity,
                    height: scaleF(48),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Reset to initial state
                        _phoneController.clear();
                        context
                            .read<AuthViewModel>()
                            .add(const AuthLogout());
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: Text(
                        'Try Another Number',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(13),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PaalvandiTheme.primaryBlue,
                        side: const BorderSide(
                            color: PaalvandiTheme.primaryBlue, width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
