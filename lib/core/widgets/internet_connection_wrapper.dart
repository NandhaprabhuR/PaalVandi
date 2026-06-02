import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import 'responsive_helper.dart';

class InternetConnectionWrapper extends StatefulWidget {
  final Widget child;

  const InternetConnectionWrapper({super.key, required this.child});

  @override
  State<InternetConnectionWrapper> createState() =>
      _InternetConnectionWrapperState();
}

class _InternetConnectionWrapperState extends State<InternetConnectionWrapper>
    with SingleTickerProviderStateMixin {
  bool _hasInternet = true;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _startConnectionChecks();
  }

  void _startConnectionChecks() {
    // Initial check
    _performCheck();
    // Periodic check every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _performCheck();
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

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildSkeletonBlock({
    required double width,
    required double height,
    double borderRadius = 8,
    EdgeInsetsGeometry? margin,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return Opacity(
          opacity: _pulseController.value * 0.45 + 0.35, // Smooth oscillation between 0.35 and 0.80
          child: Container(
            width: width,
            height: height,
            margin: margin,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.grey.shade400.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
        );
      },
    );
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
        child: Column(
          children: [
            // 1. Premium Connection Status Indicator
            Container(
              color: Colors.grey.shade50,
              padding: EdgeInsets.symmetric(vertical: scaleF(8), horizontal: scaleF(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: scaleF(12),
                    height: scaleF(12),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CustomersLoginThemeView.primaryBlue,
                    ),
                  ),
                  SizedBox(width: scaleF(8)),
                  Text(
                    'Offline · Waiting for connection...',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(11),
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // 2. High-fidelity skeleton loading dashboard (Google Pay style)
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(), // Fixed preview layout
                padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Skeleton App Bar Pill and Icons
                    Row(
                      children: [
                        _buildSkeletonBlock(width: scaleF(36), height: scaleF(36), borderRadius: 18),
                        SizedBox(width: scaleF(12)),
                        Expanded(
                          child: _buildSkeletonBlock(width: double.infinity, height: scaleF(36), borderRadius: 18),
                        ),
                        SizedBox(width: scaleF(12)),
                        _buildSkeletonBlock(width: scaleF(36), height: scaleF(36), borderRadius: 18),
                      ],
                    ),
                    SizedBox(height: scaleF(20)),
                    
                    // B. Skeleton Quick Actions Grid (8 circle slots representing quick tasks)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSkeletonBlock(width: scaleF(48), height: scaleF(48), borderRadius: 24),
                            SizedBox(height: scaleF(8)),
                            _buildSkeletonBlock(width: scaleF(40), height: scaleF(10), borderRadius: 4),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: scaleF(20)),
                    
                    // C. Skeleton Banner Advertisement Card
                    _buildSkeletonBlock(width: double.infinity, height: scaleF(110), borderRadius: 16),
                    SizedBox(height: scaleF(20)),
                    
                    // D. Skeleton Category / List Heading
                    _buildSkeletonBlock(width: scaleF(140), height: scaleF(16), borderRadius: 4),
                    SizedBox(height: scaleF(12)),
                    
                    // E. List of Skeleton Horizontal Rows
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: scaleF(12)),
                          child: Row(
                            children: [
                              _buildSkeletonBlock(width: scaleF(60), height: scaleF(60), borderRadius: 12),
                              SizedBox(width: scaleF(12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSkeletonBlock(width: scaleF(120), height: scaleF(12), borderRadius: 4),
                                    SizedBox(height: scaleF(8)),
                                    _buildSkeletonBlock(width: double.infinity, height: scaleF(10), borderRadius: 4),
                                    SizedBox(height: scaleF(4)),
                                    _buildSkeletonBlock(width: scaleF(180), height: scaleF(10), borderRadius: 4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // 3. Skeleton Bottom Navigation Bar
            Container(
              padding: EdgeInsets.symmetric(vertical: scaleF(12)),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSkeletonBlock(width: scaleF(24), height: scaleF(24), borderRadius: 12),
                      SizedBox(height: scaleF(4)),
                      _buildSkeletonBlock(width: scaleF(32), height: scaleF(8), borderRadius: 3),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
