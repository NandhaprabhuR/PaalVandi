import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/customers_login_themeview.dart';
import '../../../core/widgets/responsive_helper.dart';
import 'home_gpay_loading_line.dart';

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
                      child: const Center(
                        child: SizedBox(), // Brand name capsule commented out below (uncomment if needed later)
                        /*
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'PaalVandi',
                                  style: CustomersLoginThemeView.brandTitleStyle.copyWith(
                                    fontSize: fs(22),
                                    height: 1.0,
                                    color: CustomersLoginThemeView.primaryBlue,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'FRESH MILK, EVERY DAY',
                                  style: CustomersLoginThemeView.brandTaglineStyle.copyWith(
                                    fontSize: fs(10),
                                    height: 1.0,
                                    color: CustomersLoginThemeView.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        */
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
