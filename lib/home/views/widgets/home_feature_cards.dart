import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../theme/customers_login_themeview.dart';
import '../../../core/widgets/responsive_helper.dart';
import '../../models/home_catalog_data.dart';
import '../../../subscriptions/viewmodels/subscriptions_scope.dart';
import '../../../subscriptions/models/booked_subscription_model.dart';
import '../../../subscriptions/views/delivery_calendar_view.dart';
import '../bulk_booking_view.dart';

/// Looping micro-animations (float, wiggle, swing, pulse) to make standard emojis feel animated and premium!
class MicroAnimatedEmoji extends StatefulWidget {
  final String emoji;
  final String animationType;
  final double fontSize;

  const MicroAnimatedEmoji({
    super.key,
    required this.emoji,
    required this.animationType,
    required this.fontSize,
  });

  @override
  State<MicroAnimatedEmoji> createState() => _MicroAnimatedEmojiState();
}

class _MicroAnimatedEmojiState extends State<MicroAnimatedEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    if (widget.animationType == 'float') {
      _animation = Tween<double>(begin: -4.0, end: 4.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    } else if (widget.animationType == 'pulse') {
      _animation = Tween<double>(begin: 0.93, end: 1.07).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    } else if (widget.animationType == 'swing') {
      _animation = Tween<double>(begin: -0.04, end: 0.04).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    } else {
      // wiggle
      _animation = Tween<double>(begin: -3.5, end: 3.5).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animationType == 'float') {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: Text(
              widget.emoji,
              style: TextStyle(fontSize: widget.fontSize, height: 1.0),
            ),
          );
        },
      );
    } else if (widget.animationType == 'pulse') {
      return ScaleTransition(
        scale: _animation,
        child: Text(
          widget.emoji,
          style: TextStyle(fontSize: widget.fontSize, height: 1.0),
        ),
      );
    } else if (widget.animationType == 'swing') {
      return RotationTransition(
        turns: _animation,
        child: Text(
          widget.emoji,
          style: TextStyle(fontSize: widget.fontSize, height: 1.0),
        ),
      );
    } else {
      // wiggle
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_animation.value, 0),
            child: Text(
              widget.emoji,
              style: TextStyle(fontSize: widget.fontSize, height: 1.0),
            ),
          );
        },
      );
    }
  }
}

/// Swiggy-style category rounds displaying promotional cards and subscription dues.
/// Kept as a StatefulWidget to ensure seamless Hot Reload compatibility without state errors.
class HomeFeatureCards extends StatefulWidget {
  const HomeFeatureCards({super.key});

  @override
  State<HomeFeatureCards> createState() => _HomeFeatureCardsState();
}

class _HomeFeatureCardsState extends State<HomeFeatureCards> {
  static const List<Color> _softTints = [
    Color(0xFFE8F5E9), // Emerald green tint
    Color(0xFFF5FAFE), // Soft blue tint
    Color(0xFFF2FBF6), // Soft mint tint
    Color(0xFFFFFAF2), // Soft orange/yellow tint
    Color(0xFFF8F5FC), // Soft purple tint
    Color(0xFFFFF6F2), // Soft peach tint
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Dummy method to prevent runtime Lookup failed exceptions when an active,
  /// legacy hot-reload timer tries to invoke the old carousel auto-scroll method.
  void _nextPageForward() {}

  @override
  Widget build(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    List<BookedSubscription> bookings = [];
    try {
      bookings = SubscriptionsScope.of(context).bookings;
    } catch (_) {}

    // Build the list of promotional rounds
    final promoRounds = List.generate(HomeCatalogData.promoCards.length, (index) {
      final card = HomeCatalogData.promoCards[index];
      final bgColor = _softTints[index % _softTints.length];

      // Determine clean short title, subtitles, sizes, and fits
      String shortTitle = card.title;
      String subtitle = card.lines.isNotEmpty ? card.lines[0] : '';
      String animAsset = '';
      double lottieSize = scaleF(58);
      BoxFit lottieFit = BoxFit.contain;
      
      if (card.title.contains('Pure Fresh')) {
        shortTitle = 'Fresh Milk';
        subtitle = 'Healthy day';
        animAsset = 'assets/animations/fresh milk.json';
        lottieSize = scaleF(110); // make it much bigger to zoom in past transparent/padding margins!
        lottieFit = BoxFit.cover; // fill circular card completely
      } else if (card.title.contains('Fast Delivery')) {
        shortTitle = 'Express';
        subtitle = '20 Mins';
        animAsset = 'assets/animations/express.json';
        lottieSize = scaleF(86); // make it bigger to zoom in on the runner
        lottieFit = BoxFit.contain;
      } else if (card.title.contains('Delivery Timing')) {
        shortTitle = 'Timings';
        subtitle = '5am - 9pm';
        animAsset = 'assets/animations/ontime.json';
        lottieSize = scaleF(62); // slightly larger clock face
        lottieFit = BoxFit.contain;
      } else if (card.title.contains('Bulk Orders')) {
        shortTitle = 'Bulk Booking';
        subtitle = 'hotels, events';
        animAsset = 'assets/animations/bulk.json';
        lottieSize = scaleF(60);
        lottieFit = BoxFit.contain;
      }

      final itemWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (card.title.contains('Bulk Orders')) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BulkBookingView(
                      initialProduct: 'Fresh Cow Milk',
                    ),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(scaleF(34)),
            child: Container(
              width: scaleF(68),
              height: scaleF(68),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: lottieSize,
                height: lottieSize,
                child: Lottie.asset(
                  animAsset,
                  fit: lottieFit,
                ),
              ),
            ),
          ),
          SizedBox(height: scaleF(8)),
          Text(
            shortTitle,
            style: GoogleFonts.montserrat(
              fontSize: fs(10),
              fontWeight: FontWeight.w800,
              color: CustomersLoginThemeView.textDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: scaleF(2)),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: fs(8),
              fontWeight: FontWeight.w600,
              color: CustomersLoginThemeView.textGrey,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );

      if (bookings.isEmpty) {
        return Expanded(child: itemWidget);
      } else {
        return SizedBox(
          width: scaleF(82),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: scaleF(3)),
            child: itemWidget,
          ),
        );
      }
    });

    // If there are no bookings, render the 4 promotional rounds perfectly aligned and sized across the screen width!
    if (bookings.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: scaleF(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: promoRounds,
        ),
      );
    }

    // Build booking widgets if any exist
    final bookingWidgets = bookings.map((booking) {
      Color cardBg = const Color(0xFFE8F2FA);
      Color iconBg = const Color(0xFF1E88E5);
      final title = booking.planTitle;
      if (title.contains('Family')) {
        cardBg = const Color(0xFFE8F2FA);
        iconBg = const Color(0xFF1E88E5);
      } else if (title.contains('Business')) {
        cardBg = const Color(0xFFFFF0E0);
        iconBg = const Color(0xFFE65100);
      } else if (title.contains('Event')) {
        cardBg = const Color(0xFFF0E8F8);
        iconBg = const Color(0xFF8E24AA);
      } else if (title.contains('Smart')) {
        cardBg = const Color(0xFFE6F2EA);
        iconBg = const Color(0xFF4CAF50);
      }

      // Short plan name to fit beautifully
      final shortName = booking.planTitle.replaceAll('Subscription', '').trim();

      return SizedBox(
        width: scaleF(82),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleF(3)),
          child: InkWell(
            onTap: () {
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
            borderRadius: BorderRadius.circular(scaleF(34)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: scaleF(68),
                  height: scaleF(68),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconBg.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: iconBg.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const MicroAnimatedEmoji(
                    emoji: '📅',
                    animationType: 'pulse',
                    fontSize: 32,
                  ),
                ),
                SizedBox(height: scaleF(8)),
                Text(
                  shortName,
                  style: GoogleFonts.montserrat(
                    fontSize: fs(10),
                    fontWeight: FontWeight.w800,
                    color: CustomersLoginThemeView.textDark,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: scaleF(2)),
                Text(
                  'Calendar',
                  style: GoogleFonts.montserrat(
                    fontSize: fs(8),
                    fontWeight: FontWeight.w600,
                    color: iconBg,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: scaleF(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...bookingWidgets,
              ...promoRounds,
            ],
          ),
        ),
      ],
    );
  }
}

/*
/// OLD CAROUSEL SLIDER CODE (Preserved for comparison as per instruction)
class HomeFeatureCardsOld extends StatefulWidget {
  const HomeFeatureCardsOld({super.key});

  @override
  State<HomeFeatureCardsOld> createState() => _HomeFeatureCardsOldState();
}

class _HomeFeatureCardsOldState extends State<HomeFeatureCardsOld> {
  static const double _viewportFraction = 0.88;

  static const List<Color> _softTints = [
    Color(0xFFE8F5E9),
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
*/
