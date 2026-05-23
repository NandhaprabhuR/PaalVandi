import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../models/home_catalog_data.dart';
import 'widgets/home_feature_cards.dart';
import 'widgets/home_product_section.dart';
import 'widgets/home_top_bar.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HomeTopBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📍', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Delivering to: ${HomeCatalogData.deliveryArea}',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CustomersLoginThemeView.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: _buildAnimatedBlock(const HomeFeatureCards()),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  for (var i = 0; i < HomeCatalogData.productSections.length; i++)
                    SliverToBoxAdapter(
                      child: _buildAnimatedBlock(
                        HomeProductSection(
                          section: HomeCatalogData.productSections[i],
                          sectionIndex: i,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBlock(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
