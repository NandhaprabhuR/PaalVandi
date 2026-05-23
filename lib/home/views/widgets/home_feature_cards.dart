import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/customers_login_themeview.dart';
import '../../models/home_catalog_data.dart';

class HomeFeatureCards extends StatefulWidget {
  const HomeFeatureCards({super.key});

  @override
  State<HomeFeatureCards> createState() => _HomeFeatureCardsState();
}

class _HomeFeatureCardsState extends State<HomeFeatureCards> {
  static const double _sliderHeight = 96;
  static const double _viewportFraction = 0.88;

  static const List<Color> _softTints = [
    Color(0xFFF5FAFE),
    Color(0xFFF2FBF6),
    Color(0xFFFFFAF2),
    Color(0xFFF8F5FC),
    Color(0xFFFFF6F2),
  ];

  late final PageController _pageController;
  Timer? _timer;

  int get _cardCount => HomeCatalogData.promoCards.length;

  @override
  void initState() {
    super.initState();
    final start = _cardCount * 500;
    _pageController = PageController(
      initialPage: start,
      viewportFraction: _viewportFraction,
    );
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _nextPageForward());
  }

  void _nextPageForward() {
    if (!mounted || !_pageController.hasClients) return;
    final nextPage =
        (_pageController.page ?? _pageController.initialPage.toDouble())
            .round() +
        1;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  int _indexForPage(int page) => page % _cardCount;

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _sliderHeight,
          child: AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              return PageView.builder(
                controller: _pageController,
                itemBuilder: (context, index) {
                  final dataIndex = _indexForPage(index);
                  final page = _pageController.hasClients
                      ? (_pageController.page ?? index.toDouble())
                      : index.toDouble();
                  final distance = (page - index).abs().clamp(0.0, 1.0);
                  final scale = 1.0 - (distance * 0.03);
                  final opacity = 1.0 - (distance * 0.25);
                  final isCenter = distance < 0.05;

                  return Padding(
                    padding: EdgeInsets.only(
                      left: dataIndex == 0 ? 16 : 6,
                      right: 6,
                      top: 2,
                      bottom: 2,
                    ),
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: opacity,
                        child: _FeatureSlideCard(
                          data: HomeCatalogData.promoCards[dataIndex],
                          backgroundColor:
                              _softTints[dataIndex % _softTints.length],
                          highlighted: isCenter,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeatureSlideCard extends StatelessWidget {
  final HomePromoCardData data;
  final Color backgroundColor;
  final bool highlighted;

  const _FeatureSlideCard({
    required this.data,
    required this.backgroundColor,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: highlighted ? 0.1 : 0.05),
            blurRadius: highlighted ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: CustomersLoginThemeView.textDark,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                ...data.lines.take(2).map(
                      (line) => Text(
                        line,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: CustomersLoginThemeView.textGrey,
                          height: 1.2,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
