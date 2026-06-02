import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../profile/viewmodels/customers_profile_viewmodel.dart';
import '../../profile/views/add_address_view.dart';
import '../models/home_catalog_data.dart';
import 'widgets/home_feature_cards.dart';
import 'widgets/home_product_section.dart';
import 'widgets/home_top_bar.dart';
import 'delivery_partner_view.dart';
import '../../core/widgets/shimmer_loading.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  String _searchQuery = '';
  bool _isLocalLoading = true;

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

    // Simulate high-fidelity skeleton loading delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLocalLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showAddressPickerBottomSheet(BuildContext context) {
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);

    // List of added mock addresses
    final List<Map<String, String>> mockAddedAddresses = [
      {
        'label': 'Home',
        'houseNo': 'Flat 402, Block B',
        'apartmentName': 'Skyline Apartments',
        'street': 'Vadavalli, Coimbatore',
        'deliveryPreference': 'Deliver Here (Primary)',
      },
      {
        'label': 'Office',
        'houseNo': 'Suite 101, 3rd Floor',
        'apartmentName': 'Tidel Park',
        'street': 'Avinashi Road, Coimbatore',
        'deliveryPreference': 'Deliver Here (Primary)',
      },
      {
        'label': 'Parent\'s House',
        'houseNo': 'No. 24, Gandhi Street',
        'apartmentName': '',
        'street': 'RS Puram, Coimbatore',
        'deliveryPreference': 'Deliver to Both Places',
      },
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(scaleF(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Primary Address',
                      style: CustomersLoginThemeView.brandTitleStyle.copyWith(
                        fontSize: fs(22),
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                SizedBox(height: scaleF(12)),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: mockAddedAddresses.length,
                    itemBuilder: (context, index) {
                      final addr = mockAddedAddresses[index];
                      final displayStr = [
                        if (addr['houseNo']!.isNotEmpty) addr['houseNo']!,
                        if (addr['apartmentName']!.isNotEmpty) addr['apartmentName']!,
                        addr['street']!,
                      ].join(', ');

                      return Card(
                        margin: EdgeInsets.only(bottom: scaleF(10)),
                        elevation: 0,
                        color: Colors.grey.shade50,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: scaleF(16), vertical: scaleF(4)),
                          leading: Text(
                            addr['label'] == 'Home' ? '🏠' : (addr['label'] == 'Office' ? '🏢' : '📍'),
                            style: const TextStyle(fontSize: 22),
                          ),
                          title: Text(
                            addr['label']!,
                            style: GoogleFonts.montserrat(
                              fontSize: fs(14),
                              fontWeight: FontWeight.bold,
                              color: CustomersLoginThemeView.textDark,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayStr,
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(11),
                                  fontWeight: FontWeight.w500,
                                  color: CustomersLoginThemeView.textGrey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Preference: ${addr['deliveryPreference']}',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(10),
                                  fontWeight: FontWeight.bold,
                                  color: CustomersLoginThemeView.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Update dynamic state in BLoC
                            context.read<CustomersProfileViewModel>().add(
                                  ProfileFieldChanged(
                                    houseNo: addr['houseNo'],
                                    apartmentName: addr['apartmentName'],
                                    street: addr['street'],
                                    deliveryPreference: addr['deliveryPreference'],
                                  ),
                                );
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: scaleF(12)),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddAddressView(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white, size: 18),
                  label: Text(
                    'Add New Address',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(14),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomersLoginThemeView.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: scaleF(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = ResponsiveHelper.horizontalPadding(context);
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);

    return Scaffold(
      backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeTopBar(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query.trim().toLowerCase();
                });
              },
            ),
            BlocBuilder<CustomersProfileViewModel, CustomersProfileState>(
              builder: (context, profileState) {
                final model = profileState.model;
                String displayAddress = HomeCatalogData.deliveryArea;
                if (model.street.isNotEmpty) {
                  final parts = [
                    if (model.houseNo.isNotEmpty) model.houseNo,
                    if (model.apartmentName.isNotEmpty) model.apartmentName,
                    model.street,
                  ];
                  displayAddress = '${parts.join(', ')} (${model.deliveryPreference})';
                }

                return Padding(
                  padding: EdgeInsets.fromLTRB(hPadding, scaleF(4), hPadding, scaleF(2)),
                  child: Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showAddressPickerBottomSheet(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('📍', style: TextStyle(fontSize: fs(16))),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Delivering to: $displayAddress',
                                style: GoogleFonts.montserrat(
                                  fontSize: fs(13),
                                  fontWeight: FontWeight.w600,
                                  color: CustomersLoginThemeView.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: CustomersLoginThemeView.primaryBlue,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: _isLocalLoading
                  ? _buildShimmerSkeleton(context, hPadding, scaleF, fs)
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      slivers: [
                        SliverToBoxAdapter(child: SizedBox(height: scaleF(12))),
                        const SliverToBoxAdapter(
                          child: HomeFeatureCards(),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: scaleF(16))),
                        SliverToBoxAdapter(
                          child: _buildDeliveryAndTrackingCards(context, hPadding, scaleF, fs),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: scaleF(20))),
                        ...() {
                          final queryTokens = _searchQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
                          final filteredSections = HomeCatalogData.productSections.map((section) {
                            final matchingProducts = section.products.where((item) {
                              if (queryTokens.isEmpty) return true;
                              final fullNameAndQty = '${section.productName} ${item.quantity}'.toLowerCase();
                              return queryTokens.every((token) => fullNameAndQty.contains(token));
                            }).toList();

                            if (matchingProducts.isNotEmpty) {
                              return HomeProductSectionData(
                                heading: section.heading,
                                productName: section.productName,
                                showDepositBadge: section.showDepositBadge,
                                showRefillBadge: section.showRefillBadge,
                                products: matchingProducts,
                              );
                            }
                            return null;
                          }).whereType<HomeProductSectionData>().toList();

                          return List.generate(filteredSections.length, (i) {
                            return SliverToBoxAdapter(
                              child: HomeProductSection(
                                key: ValueKey('${filteredSections[i].productName}_${filteredSections[i].products.length}_$i'),
                                section: filteredSections[i],
                                sectionIndex: i,
                              ),
                            );
                          });
                        }(),
                        SliverToBoxAdapter(
                          child: _buildTrustSection(context, hPadding, scaleF, fs),
                        ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: scaleF(12), bottom: scaleF(4)),
                      child: Center(
                        child: Lottie.asset(
                          'assets/animations/homebottom.json',
                          height: scaleF(130),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: scaleF(24))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAndTrackingCards(
      BuildContext context, double hPadding, double Function(double) scaleF, double Function(double) fs) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Row(
        children: [
          // Card 1: Delivery Available info
          Expanded(
            child: Container(
              padding: EdgeInsets.all(scaleF(14)),
              height: scaleF(95),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Delivery Info',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(12),
                      fontWeight: FontWeight.bold,
                      color: CustomersLoginThemeView.textDark,
                    ),
                  ),
                  SizedBox(height: scaleF(8)),
                  Text(
                    'Delivering in 20 Mins\n5:00 AM – 9:00 PM',
                    style: GoogleFonts.montserrat(
                      fontSize: fs(10),
                      fontWeight: FontWeight.w600,
                      color: CustomersLoginThemeView.textGrey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: scaleF(12)),
          // Card 2: Track Order interactive
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DeliveryPartnerView(orderId: 'PV98302X'),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.all(scaleF(14)),
                height: scaleF(95),
                decoration: BoxDecoration(
                  color: CustomersLoginThemeView.primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: CustomersLoginThemeView.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Track Order',
                            style: GoogleFonts.montserrat(
                              fontSize: fs(12),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 10),
                      ],
                    ),
                    SizedBox(height: scaleF(8)),
                    Text(
                      'Live tracking for order #PV98302X',
                      style: GoogleFonts.montserrat(
                        fontSize: fs(10),
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustSection(
      BuildContext context, double hPadding, double Function(double) scaleF, double Function(double) fs) {
    final List<Map<String, dynamic>> timelineSteps = [
      {
        'title': '✓ Pure Farm Fresh Milk',
        'desc': 'Directly from happy free-roaming cows, 100% natural.',
        'bgColor': const Color(0xFFFFFDE7), // Soft yellow pastel
        'accentColor': const Color(0xFFFBC02D), // Golden yellow
        'pngIcon': 'assets/icons/freshmilk.png',
      },
      {
        'title': '✓ No Water Added',
        'desc': 'Thick, creamy, raw whole milk as nature intended.',
        'bgColor': const Color(0xFFE3F2FD), // Soft blue pastel
        'accentColor': const Color(0xFF1E88E5), // Ocean blue
        'pngIcon': 'assets/icons/nowater.png',
      },
      {
        'title': '✓ No Preservatives',
        'desc': 'Zero chemicals, synthetic additives, or enhancers.',
        'bgColor': const Color(0xFFFCE4EC), // Soft pink pastel
        'accentColor': const Color(0xFFD81B60), // Vibrant pink
        'pngIcon': 'assets/icons/tested.png',
      },
      {
        'title': '✓ Glass Bottle Delivery',
        'desc': 'Delivered in premium hygienically sterilized glass bottles.',
        'bgColor': const Color(0xFFE8F5E9), // Soft mint green pastel
        'accentColor': const Color(0xFF4CAF50), // Mint green
        'pngIcon': 'assets/icons/milkbottle.png',
      },
      {
        'title': '✓ Bring Your Own Container',
        'desc': 'Flexible eco-friendly container refilling options at your doorstep.',
        'bgColor': const Color(0xFFE0F7FA), // Soft teal pastel
        'accentColor': const Color(0xFF00ACC1), // Teal
        'pngIcon': 'assets/icons/localfarms.png',
      },
      {
        'title': '✓ Fresh Daily Collection',
        'desc': 'Chilled instantly and delivered within hours of milking.',
        'bgColor': const Color(0xFFF3E5F5), // Soft purple/lavender pastel
        'accentColor': const Color(0xFF8E24AA), // Purple
        'pngIcon': 'assets/icons/refridgerator.png',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Why PaalVandi? ',
            style: CustomersLoginThemeView.brandTitleStyle.copyWith(
              fontSize: fs(18),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: scaleF(16)),
          Column(
            children: List.generate(timelineSteps.length, (index) {
              final step = timelineSteps[index];
              final title = step['title'] as String;
              final desc = step['desc'] as String;
              final bgColor = step['bgColor'] as Color;
              final accentColor = step['accentColor'] as Color;
              final pngIcon = step['pngIcon'] as String;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Timeline track and node with beautiful custom PNG icons
                    Container(
                      width: scaleF(36),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: index == 0 ? scaleF(16) : 0,
                            bottom: index == timelineSteps.length - 1 ? scaleF(16) : 0,
                            child: Container(
                              width: 2,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          SizedBox(
                            width: scaleF(32),
                            height: scaleF(32),
                            child: Image.asset(
                              pngIcon,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.circle, size: 8, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: scaleF(12)),
                    // Colorful Pastel Card without internal outline icons
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: scaleF(12)),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Left vertical color accent strip
                            Container(
                              width: scaleF(4),
                              height: scaleF(28),
                              margin: EdgeInsets.only(left: scaleF(12)),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: scaleF(12)),
                            // Card text details
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: scaleF(12),
                                  horizontal: scaleF(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      title,
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(12),
                                        fontWeight: FontWeight.bold,
                                        color: CustomersLoginThemeView.textDark,
                                      ),
                                    ),
                                    SizedBox(height: scaleF(4)),
                                    Text(
                                      desc,
                                      style: GoogleFonts.montserrat(
                                        fontSize: fs(10),
                                        fontWeight: FontWeight.w500,
                                        color: CustomersLoginThemeView.textGrey,
                                        height: 1.35,
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
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget _buildShimmerSkeleton(BuildContext context, double hPadding, double Function(double) scaleF, double Function(double) fs) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: scaleF(12)),
      children: [
        // 1. Swiggy/GPay-style Feature rounds shimmer (4 side-by-side circular rounds)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleF(4), vertical: scaleF(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerSkeleton(
                    width: scaleF(68),
                    height: scaleF(68),
                    borderRadius: 34,
                  ),
                  SizedBox(height: scaleF(8)),
                  ShimmerSkeleton(
                    width: scaleF(55),
                    height: scaleF(10),
                    borderRadius: 4,
                  ),
                  SizedBox(height: scaleF(4)),
                  ShimmerSkeleton(
                    width: scaleF(40),
                    height: scaleF(8),
                    borderRadius: 4,
                  ),
                ],
              );
            }),
          ),
        ),
        SizedBox(height: scaleF(16)),
        
        // 2. High-fidelity Delivery and Tracking Cards Shimmer (2 side-by-side outline cards)
        Row(
          children: [
            Expanded(
              child: Container(
                height: scaleF(95),
                padding: EdgeInsets.all(scaleF(14)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerSkeleton(width: scaleF(70), height: scaleF(12), borderRadius: 3),
                    SizedBox(height: scaleF(8)),
                    ShimmerSkeleton(width: scaleF(100), height: scaleF(10), borderRadius: 3),
                    SizedBox(height: scaleF(6)),
                    ShimmerSkeleton(width: scaleF(80), height: scaleF(10), borderRadius: 3),
                  ],
                ),
              ),
            ),
            SizedBox(width: scaleF(12)),
            Expanded(
              child: Container(
                height: scaleF(95),
                padding: EdgeInsets.all(scaleF(14)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerSkeleton(width: scaleF(75), height: scaleF(12), borderRadius: 3),
                    SizedBox(height: scaleF(8)),
                    ShimmerSkeleton(width: scaleF(105), height: scaleF(10), borderRadius: 3),
                    SizedBox(height: scaleF(6)),
                    ShimmerSkeleton(width: scaleF(60), height: scaleF(10), borderRadius: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: scaleF(24)),
        
        // 3. Section Heading Shimmer
        Row(
          children: [
            ShimmerSkeleton(
              width: scaleF(120),
              height: scaleF(18),
              borderRadius: 4,
            ),
          ],
        ),
        SizedBox(height: scaleF(12)),
        
        // 4. Products Grid Shimmer - exactly matching the real cards! (2 horizontal columns)
        Row(
          children: List.generate(2, (index) {
            final cardBg = index == 0 ? const Color(0xFFEEF5FF) : const Color(0xFFE8F6EC);
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == 0 ? scaleF(12) : 0),
                height: scaleF(205),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.15), width: 1),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(scaleF(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ShimmerSkeleton(
                              width: scaleF(52),
                              height: scaleF(52),
                              borderRadius: 14,
                            ),
                          ),
                          SizedBox(height: scaleF(8)),
                          ShimmerSkeleton(width: scaleF(90), height: scaleF(12), borderRadius: 3),
                          SizedBox(height: scaleF(6)),
                          ShimmerSkeleton(width: scaleF(70), height: scaleF(8), borderRadius: 2),
                          SizedBox(height: scaleF(4)),
                          ShimmerSkeleton(width: scaleF(50), height: scaleF(8), borderRadius: 2),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShimmerSkeleton(width: scaleF(30), height: scaleF(12), borderRadius: 3),
                              ShimmerSkeleton(width: scaleF(35), height: scaleF(14), borderRadius: 3),
                            ],
                          ),
                          SizedBox(height: scaleF(6)),
                          Row(
                            children: [
                              ShimmerSkeleton(width: scaleF(25), height: scaleF(10), borderRadius: 2),
                              SizedBox(width: scaleF(4)),
                              ShimmerSkeleton(width: scaleF(45), height: scaleF(8), borderRadius: 2),
                            ],
                          ),
                          SizedBox(height: scaleF(2)),
                        ],
                      ),
                    ),
                    Positioned(
                      right: scaleF(8),
                      bottom: scaleF(8),
                      child: ShimmerSkeleton(
                        width: scaleF(32),
                        height: scaleF(32),
                        borderRadius: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

