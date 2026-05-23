import 'package:flutter/material.dart';
import '../../../theme/customers_login_themeview.dart';

/// Thin segment that scrolls continuously to the right (no snap-back reset).
class HomeGPayLoadingLine extends StatefulWidget {
  const HomeGPayLoadingLine({super.key});

  @override
  State<HomeGPayLoadingLine> createState() => _HomeGPayLoadingLineState();
}

class _HomeGPayLoadingLineState extends State<HomeGPayLoadingLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            const segmentWidth = 48.0;
            final cycle = trackWidth + segmentWidth;
            final offset = (_controller.value * cycle) % cycle;

            return SizedBox(
              height: 3,
              width: trackWidth,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  _segmentAt(offset - segmentWidth, segmentWidth),
                  _segmentAt(offset, segmentWidth),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _segmentAt(double left, double width) {
    return Positioned(
      left: left,
      top: 0,
      bottom: 0,
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CustomersLoginThemeView.primaryBlue,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.45),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}
