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
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: scaleF(12))),
                  SliverToBoxAdapter(
                    child: _buildAnimatedBlock(const HomeFeatureCards()),
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
                        child: _buildAnimatedBlock(
                          HomeProductSection(
                            key: ValueKey('${filteredSections[i].productName}_${filteredSections[i].products.length}_$i'),
                            section: filteredSections[i],
                            sectionIndex: i,
                          ),
                        ),
                      );
                    });
                  }(),
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
