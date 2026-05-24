import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/customers_login_themeview.dart';
import '../../../core/widgets/responsive_helper.dart';
import '../../models/home_catalog_data.dart';
import '../../../subscriptions/viewmodels/subscriptions_scope.dart';
import '../../../subscriptions/models/booked_subscription_model.dart';
import '../../../subscriptions/views/delivery_calendar_view.dart';

class HomeFeatureCards extends StatefulWidget {
  const HomeFeatureCards({super.key});

  @override
  State<HomeFeatureCards> createState() => _HomeFeatureCardsState();
}

class _HomeFeatureCardsState extends State<HomeFeatureCards> {
  static const double _viewportFraction = 0.88;

  static const List<Color> _softTints = [
    Color(0xFFE8F5E9), // Emerald green tint for tracker card
    Color(0xFFF5FAFE),
    Color(0xFFF2FBF6),
    Color(0xFFFFFAF2),
    Color(0xFFF8F5FC),
    Color(0xFFFFF6F2),
  ];

  late final PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1000,
      viewportFraction: _viewportFraction,
    );
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _nextPageForward());
  }

  void _nextPageForward() {
    if (!mounted || !_pageController.hasClients) return;
    final nextPage =
        (_pageController.page ?? _pageController.initialPage.toDouble())
            .round() +
        1;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sliderHeight = ResponsiveHelper.scaleHeight(context, 102).clamp(90.0, 130.0);
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    List<BookedSubscription> bookings = [];
    try {
      bookings = SubscriptionsScope.of(context).bookings;
    } catch (_) {}

    final totalCardsCount = HomeCatalogData.promoCards.length + bookings.length;

    return Column(
      children: [
        SizedBox(
          height: sliderHeight,
          child: AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              return PageView.builder(
                controller: _pageController,
                itemBuilder: (context, index) {
                  final dataIndex = index % totalCardsCount;
                  final page = _pageController.hasClients
                      ? (_pageController.page ?? index.toDouble())
                      : index.toDouble();
                  final distance = (page - index).abs().clamp(0.0, 1.0);
                  final scale = 1.0 - (distance * 0.03);
                  final opacity = 1.0 - (distance * 0.25);
                  final isCenter = distance < 0.05;

                  final bool isDeliveryStatsCard = dataIndex < bookings.length;

                  Color cardBg = const Color(0xFFE8F5E9);
                  Color highlightColor = const Color(0xFF2E7D32);
                  Color buttonColor = const Color(0xFF4CAF50);

                  if (isDeliveryStatsCard) {
                    final title = bookings[dataIndex].planTitle;
                    if (title.contains('Family')) {
                      cardBg = const Color(0xFFE8F2FA);
                      highlightColor = const Color(0xFF1565C0);
                      buttonColor = const Color(0xFF1E88E5);
                    } else if (title.contains('Business')) {
                      cardBg = const Color(0xFFFFF0E0);
                      highlightColor = const Color(0xFFE65100);
                      buttonColor = const Color(0xFFF57C00);
                    } else if (title.contains('Event')) {
                      cardBg = const Color(0xFFF0E8F8);
                      highlightColor = const Color(0xFF4A148C);
                      buttonColor = const Color(0xFF8E24AA);
                    } else if (title.contains('Smart')) {
                      cardBg = const Color(0xFFE6F2EA);
                      highlightColor = const Color(0xFF1B5E20);
                      buttonColor = const Color(0xFF4CAF50);
                    }
                  }

                  return Padding(
                    padding: EdgeInsets.only(
                      left: dataIndex == 0 ? scaleF(16) : scaleF(6),
                      right: scaleF(6),
                      top: 2,
                      bottom: 2,
                    ),
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: opacity,
                        child: isDeliveryStatsCard
                            ? _DeliveryStatsSlideCard(
                                booking: bookings[dataIndex],
                                backgroundColor: cardBg,
                                highlightColor: highlightColor,
                                buttonColor: buttonColor,
                                highlighted: isCenter,
                              )
                            : _FeatureSlideCard(
                                data: HomeCatalogData.promoCards[dataIndex - bookings.length],
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

class _DeliveryStatsSlideCard extends StatelessWidget {
  final BookedSubscription booking;
  final Color backgroundColor;
  final Color highlightColor;
  final Color buttonColor;
  final bool highlighted;

  const _DeliveryStatsSlideCard({
    required this.booking,
    required this.backgroundColor,
    required this.highlightColor,
    required this.buttonColor,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: buttonColor.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: highlighted ? 0.08 : 0.04),
            blurRadius: highlighted ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: scaleF(14), vertical: scaleF(10)),
      child: Row(
        children: [
          Text(
            '📅',
            style: TextStyle(
              fontSize: fs(26),
            ),
          ),
          SizedBox(width: scaleF(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${booking.planTitle} ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(13.5),
                    fontWeight: FontWeight.w800,
                    color: highlightColor,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: scaleF(3)),
                Text(
                  'Delivered: 12 days / 30 days',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(11),
                    fontWeight: FontWeight.w700,
                    color: CustomersLoginThemeView.textDark,
                  ),
                ),
                Text(
                  'Next: Tomorrow, 6:30 AM',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(10),
                    fontWeight: FontWeight.w500,
                    color: CustomersLoginThemeView.textGrey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: scaleF(8)),
          SizedBox(
            height: scaleF(32),
            child: ElevatedButton(
              onPressed: () {
                final store = SubscriptionsScope.of(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SubscriptionsScope(
                      store: store,
                      child: DeliveryCalendarView(booking: booking),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: scaleF(14)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'View',
                style: GoogleFonts.montserrat(
                  fontSize: fs(12),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

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
      padding: EdgeInsets.symmetric(horizontal: scaleF(12), vertical: scaleF(8)),
      child: Row(
        children: [
          Text(
            data.emoji,
            style: TextStyle(
              fontSize: fs(26),
            ),
          ),
          SizedBox(width: scaleF(10)),
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
                    fontSize: fs(14),
                    fontWeight: FontWeight.w800,
                    color: CustomersLoginThemeView.textDark,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: scaleF(4)),
                ...data.lines.take(2).map(
                      (line) => Text(
                        line,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: fs(10),
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
