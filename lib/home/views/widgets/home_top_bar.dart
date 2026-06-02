import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/customers_login_themeview.dart';
import '../../../core/widgets/responsive_helper.dart';
import 'home_gpay_loading_line.dart';
import '../notifications_view.dart';

class HomeTopBar extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;

  const HomeTopBar({super.key, this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    final barHeight = ResponsiveHelper.scaleHeight(context, 120).clamp(115.0, 145.0);
    final searchOverlap = ResponsiveHelper.scaleHeight(context, 22).clamp(16.0, 26.0);
    final horizontalInset = ResponsiveHelper.horizontalPadding(context, baseValue: 20);
    final searchRadius = ResponsiveHelper.scaleWidth(context, 30).clamp(24.0, 36.0);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    final OutlineInputBorder searchBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(searchRadius),
      borderSide: const BorderSide(
        color: CustomersLoginThemeView.primaryBlue,
        width: 1.5,
      ),
    );

    final OutlineInputBorder searchFocusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(searchRadius),
      borderSide: const BorderSide(
        color: CustomersLoginThemeView.primaryBlue,
        width: 2.5,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: SizedBox(
        height: barHeight + searchOverlap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: barHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: CustomersLoginThemeView.cardBackgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: CustomersLoginThemeView.primaryBlue,
                    width: 3,
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/topbar/hometopbar.png',
                      fit: BoxFit.cover,
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, barHeight * 0.3),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Center(
                              child: SizedBox(),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.notifications_none_rounded,
                                          color: CustomersLoginThemeView.primaryBlue,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => const NotificationsView(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      right: 2,
                                      top: 2,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: horizontalInset,
            right: horizontalInset,
            bottom: 0,
            child: Material(
              elevation: 4,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(searchRadius),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  TextField(
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search for products...',
                      hintStyle: CustomersLoginThemeView.hintStyle.copyWith(
                        fontSize: fs(14),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: CustomersLoginThemeView.primaryBlue,
                        size: ResponsiveHelper.scaleWidth(context, 22).clamp(18.0, 26.0),
                      ),
                      filled: true,
                      fillColor: CustomersLoginThemeView.cardBackgroundColor,
                      contentPadding: const EdgeInsets.fromLTRB(
                        0,
                        12,
                        0,
                        14,
                      ),
                      border: searchBorder,
                      enabledBorder: searchBorder,
                      focusedBorder: searchFocusedBorder,
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(searchRadius),
                        bottomRight: Radius.circular(searchRadius),
                      ),
                      child: const HomeGPayLoadingLine(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
