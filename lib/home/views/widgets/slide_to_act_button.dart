import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/delivery_theme.dart';
import '../../../core/widgets/responsive_helper.dart';

class SlideToActButton extends StatefulWidget {
  final String text;
  final VoidCallback onSubmitted;
  final Color backgroundColor;
  final Color sliderColor;

  const SlideToActButton({
    super.key,
    required this.text,
    required this.onSubmitted,
    this.backgroundColor = DeliveryTheme.cardDark,
    this.sliderColor = DeliveryTheme.primaryOrange,
  });

  @override
  State<SlideToActButton> createState() => _SlideToActButtonState();
}

class _SlideToActButtonState extends State<SlideToActButton> with SingleTickerProviderStateMixin {
  double _dragProgress = 0.0; // 0.0 to 1.0
  late AnimationController _animController;
  late Animation<double> _returnAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    
    _returnAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxWidth) {
    final dragDelta = details.primaryDelta ?? 0.0;
    // Calculate progress based on slide width minus the handle size
    final maxDragDistance = maxWidth - 56.0; 
    if (maxDragDistance <= 0) return;

    setState(() {
      _dragProgress += dragDelta / maxDragDistance;
      _dragProgress = _dragProgress.clamp(0.0, 1.0);
    });
  }

  void _onDragEnd() {
    if (_dragProgress >= 0.85) {
      // Completed! Trigger callback and animate to 100%
      setState(() {
        _dragProgress = 1.0;
      });
      widget.onSubmitted();
    } else {
      // Return back to starting position with a bouncy spring animation
      _returnAnimation = Tween<double>(begin: _dragProgress, end: 0.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
      )..addListener(() {
          setState(() {
            _dragProgress = _returnAnimation.value;
          });
        });
      
      _animController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs = (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final handleSize = scaleF(52);
        final availableDragDistance = totalWidth - handleSize - 8.0;

        return Container(
          width: totalWidth,
          height: scaleF(56),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DeliveryTheme.borderDark, width: 1.5),
          ),
          padding: const EdgeInsets.all(4),
          child: Stack(
            children: [
              // Slide background shimmering text description
              Center(
                child: Opacity(
                  opacity: (1.0 - _dragProgress * 1.5).clamp(0.0, 1.0),
                  child: Text(
                    widget.text,
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.w800,
                      color: DeliveryTheme.textLight.withOpacity(0.85),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Highlight/Reveal progress bar behind
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: handleSize + (_dragProgress * availableDragDistance),
                  decoration: BoxDecoration(
                    color: widget.sliderColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Interactive Draggable Handle (Swiggy Orange Arrow Button)
              Positioned(
                left: _dragProgress * availableDragDistance,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) => _onDragUpdate(details, totalWidth),
                  onHorizontalDragEnd: (details) => _onDragEnd(),
                  child: Container(
                    width: handleSize,
                    height: handleSize,
                    decoration: BoxDecoration(
                      color: widget.sliderColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: widget.sliderColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _dragProgress >= 0.95 ? Icons.check_circle_outline : Icons.chevron_right,
                        color: Colors.white,
                        size: scaleF(28),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
