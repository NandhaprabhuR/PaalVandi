import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/app_navigation.dart';
import '../../core/app_route_storage.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';

class DeleteAccountView extends StatefulWidget {
  const DeleteAccountView({super.key});

  @override
  State<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends State<DeleteAccountView> {
  int _step = 0; // 0: Mobile Input, 1: OTP Input, 2: Success Deletion Lottie
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  // Countdown timer for OTP
  int _timerSeconds = 60;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _mobileController.dispose();
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

  void _sendOtp() async {
    final mobile = _mobileController.text.trim();
    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid 10-digit mobile number.',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _step = 1;
    });
    _startTimer();
  }

  void _verifyAndDelete() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid 6-digit OTP code.',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _step = 2;
    });

    // Auto-pop or navigate to login after Lottie is shown
    Future.delayed(const Duration(milliseconds: 2500), () async {
      await AppRouteStorage.clearSession();
      if (mounted) {
        context.goPersist('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final hPadding = ResponsiveHelper.horizontalPadding(context);

    if (_step == 2) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/accountdeletedsuccessfully.json',
                  width: scaleF(160),
                  height: scaleF(160),
                  fit: BoxFit.contain,
                  repeat: false,
                ),
                SizedBox(height: scaleF(24)),
                Text(
                  'Account Deleted',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(22),
                    fontWeight: FontWeight.w800,
                    color: CustomersLoginThemeView.sectionHeadingRed,
                  ),
                ),
                SizedBox(height: scaleF(8)),
                Text(
                  'Your account and data have been permanently removed. Thank you for being with PaalVandi.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(13),
                    fontWeight: FontWeight.w500,
                    color: CustomersLoginThemeView.textGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: CustomersLoginThemeView.primaryBlue,
              size: scaleF(24).clamp(20.0, 28.0),
            ),
            onPressed: _isLoading
                ? null
                : () {
                    if (_step == 1) {
                      setState(() => _step = 0);
                    } else {
                      Navigator.pop(context);
                    }
                  },
          ),
          title: Text(
            'Delete Account',
            style: CustomersLoginThemeView.brandTitleStyle.copyWith(
              fontSize: fs(20),
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPadding, scaleF(16), hPadding, scaleF(32)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_step == 0) ...[
                  // Step 1: Mobile Input Screen
                  Lottie.asset(
                    'assets/animations/Accountdelete.json',
                    height: scaleF(140).clamp(120.0, 180.0),
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: scaleF(16)),
                  Text(
                    'We are sorry to see you go',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(18),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: scaleF(8)),
                  Text(
                    'Please enter your registered 10-digit mobile number to begin the deletion verification process.',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(12),
                      color: CustomersLoginThemeView.textGrey,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: scaleF(32)),

                  Text(
                    'Mobile Number',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(13),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                  SizedBox(height: scaleF(8)),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.5), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: scaleF(16)),
                          child: Text(
                            '+91',
                            style: TextStyle(
                              fontSize: fs(16),
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.textGrey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            style: TextStyle(
                              fontSize: fs(16),
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.textDark,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter 10-digit number',
                              hintStyle: CustomersLoginThemeView.hintStyle.copyWith(fontSize: fs(14)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: scaleF(12), vertical: scaleF(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: scaleF(40)),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: CustomersLoginThemeView.primaryBlue))
                  else
                    SizedBox(
                      height: scaleF(48).clamp(42.0, 54.0),
                      child: ElevatedButton(
                        onPressed: _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomersLoginThemeView.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Send Verification OTP',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ] else ...[
                  // Step 2: OTP Input Screen
                  Lottie.asset(
                    'assets/animations/otpscreen.json',
                    height: scaleF(140).clamp(120.0, 180.0),
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: scaleF(16)),
                  Text(
                    'Verify Deletion Code',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(18),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: scaleF(8)),
                  Text(
                    'Enter the 6-digit code sent to +91 ${_mobileController.text}.',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(12),
                      color: CustomersLoginThemeView.textGrey,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: scaleF(32)),

                  Text(
                    'Enter 6-Digit OTP',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(13),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                  SizedBox(height: scaleF(8)),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: CustomersLoginThemeView.sectionHeadingRed.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
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
                      style: TextStyle(
                        fontSize: fs(16),
                        letterSpacing: 8,
                        color: CustomersLoginThemeView.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '000000',
                        hintStyle: CustomersLoginThemeView.hintStyle.copyWith(letterSpacing: 8, fontSize: fs(16)),
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(vertical: scaleF(16)),
                      ),
                    ),
                  ),
                  SizedBox(height: scaleF(20)),

                  // Resend OTP text or countdown timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _timerSeconds > 0 ? 'Resend in ${_timerSeconds}s' : 'Didn\'t receive code?',
                        style: GoogleFonts.montserrat(
                          fontSize: fs(11),
                          fontWeight: FontWeight.w600,
                          color: CustomersLoginThemeView.textGrey,
                        ),
                      ),
                      if (_timerSeconds == 0)
                        GestureDetector(
                          onTap: _startTimer,
                          child: Text(
                            'Resend OTP',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(11),
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.primaryBlue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: scaleF(40)),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: CustomersLoginThemeView.sectionHeadingRed))
                  else
                    SizedBox(
                      height: scaleF(48).clamp(42.0, 54.0),
                      child: ElevatedButton(
                        onPressed: _verifyAndDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Verify & Delete Account',
                          style: GoogleFonts.montserrat(
                            fontSize: fs(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
