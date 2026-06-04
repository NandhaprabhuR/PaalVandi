import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/paalvandi_theme.dart';
import 'responsive_helper.dart';

class ImageCarouselDialog extends StatefulWidget {
  final List<String> imageUrls;
  final String title;

  const ImageCarouselDialog({
    super.key,
    required this.imageUrls,
    required this.title,
  });

  @override
  State<ImageCarouselDialog> createState() => _ImageCarouselDialogState();
}

class _ImageCarouselDialogState extends State<ImageCarouselDialog> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleF = (num val) => ResponsiveHelper.scaledValue(context, val.toDouble());
    final fs = (num size) => ResponsiveHelper.scaledFontSize(context, size.toDouble());

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(scaleF(20)),
      child: Container(
        decoration: BoxDecoration(
          color: PaalvandiTheme.bgCream,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 2),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.montserrat(
                        fontSize: fs(14),
                        fontWeight: FontWeight.bold,
                        color: PaalvandiTheme.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(scaleF(4)),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Icon(Icons.close, size: scaleF(16), color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            
            // Carousel
            SizedBox(
              height: scaleF(250),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: widget.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.imageUrls[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: PaalvandiTheme.primaryBlue,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Left Arrow
                  if (_currentIndex > 0)
                    Positioned(
                      left: scaleF(8),
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(scaleF(6)),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Icon(Icons.chevron_left, size: scaleF(20)),
                          ),
                        ),
                      ),
                    ),
                  // Right Arrow
                  if (_currentIndex < widget.imageUrls.length - 1)
                    Positioned(
                      right: scaleF(8),
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(scaleF(6)),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Icon(Icons.chevron_right, size: scaleF(20)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Dots
            if (widget.imageUrls.length > 1)
              Padding(
                padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.imageUrls.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: scaleF(4)),
                      width: scaleF(_currentIndex == index ? 10 : 6),
                      height: scaleF(6),
                      decoration: BoxDecoration(
                        color: _currentIndex == index ? PaalvandiTheme.primaryBlue : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(scaleF(3)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
