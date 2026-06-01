import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../theme/customers_login_themeview.dart';
import 'responsive_helper.dart';

class InternetConnectionWrapper extends StatefulWidget {
  final Widget child;

  const InternetConnectionWrapper({super.key, required this.child});

  @override
  State<InternetConnectionWrapper> createState() =>
      _InternetConnectionWrapperState();
}

class _InternetConnectionWrapperState extends State<InternetConnectionWrapper> {
  bool _hasInternet = true;
  Timer? _timer;
  bool _checkingNow = false;

  @override
  void initState() {
    super.initState();
    _startConnectionChecks();
  }

  void _startConnectionChecks() {
    // Initial check
    _performCheck();
    // Periodic check every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_checkingNow) {
        _performCheck();
      }
    });
  }

  Future<void> _performCheck() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      final active = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (mounted && _hasInternet != active) {
        setState(() => _hasInternet = active);
      }
    } catch (_) {
      if (mounted && _hasInternet) {
        setState(() => _hasInternet = false);
      }
    }
  }

  Future<void> _manualRetry() async {
    setState(() => _checkingNow = true);
    // Give it a tiny simulated delay for premium feedback
    await Future.delayed(const Duration(milliseconds: 500));
    await _performCheck();
    if (mounted) {
      setState(() => _checkingNow = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasInternet) {
      return widget.child;
    }

    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: scaleF(24)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/nointernet.json',
                  width: scaleF(240).clamp(180.0, 300.0),
                  height: scaleF(240).clamp(180.0, 300.0),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: scaleF(16)),
                Text(
                  'Check your internet connection',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(18),
                    fontWeight: FontWeight.w800,
                    color: CustomersLoginThemeView.textDark,
                  ),
                ),
                SizedBox(height: scaleF(8)),
                Text(
                  'Please check your network settings and try again.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(13),
                    fontWeight: FontWeight.w500,
                    color: CustomersLoginThemeView.textGrey,
                  ),
                ),
                SizedBox(height: scaleF(36)),
                SizedBox(
                  width: double.infinity,
                  height: scaleF(46).clamp(40.0, 52.0),
                  child: ElevatedButton(
                    onPressed: _checkingNow ? null : _manualRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomersLoginThemeView.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _checkingNow
                        ? SizedBox(
                            width: scaleF(20),
                            height: scaleF(20),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Retry',
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
        ),
      ),
    );
  }
}
