import 'package:flutter/material.dart';
import '../../../theme/customers_login_themeview.dart';
import 'home_gpay_loading_line.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  static const double barHeight = 100;
  static const double searchOverlap = 22;
  static const double _horizontalInset = 20;
  static const double _searchRadius = 30;

  static final OutlineInputBorder _searchBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(_searchRadius),
    borderSide: const BorderSide(
      color: CustomersLoginThemeView.primaryBlue,
      width: 1.5,
    ),
  );

  static final OutlineInputBorder _searchFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(_searchRadius),
    borderSide: const BorderSide(
      color: CustomersLoginThemeView.primaryBlue,
      width: 2.5,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: barHeight + searchOverlap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: barHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
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
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PaalVandi',
                          style:
                              CustomersLoginThemeView.brandTitleStyle.copyWith(
                            fontSize: 22,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'FRESH MILK, EVERY DAY',
                          style: CustomersLoginThemeView.brandTaglineStyle
                              .copyWith(
                            fontSize: 10,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: _horizontalInset,
            right: _horizontalInset,
            bottom: 0,
            child: Material(
              elevation: 4,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(_searchRadius),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for products...',
                      hintStyle: CustomersLoginThemeView.hintStyle,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: CustomersLoginThemeView.primaryBlue,
                        size: 22,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.fromLTRB(
                        0,
                        12,
                        0,
                        14,
                      ),
                      border: _searchBorder,
                      enabledBorder: _searchBorder,
                      focusedBorder: _searchFocusedBorder,
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(_searchRadius),
                        bottomRight: Radius.circular(_searchRadius),
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
    );
  }
}
