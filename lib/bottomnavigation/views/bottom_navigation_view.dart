import 'package:flutter/material.dart';
import '../../cart/viewmodels/cart_scope.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';
import '../../cart/views/cart_tab_view.dart';
import '../../core/app_route_storage.dart';
import '../../home/views/home_tab_view.dart';
import '../../profile/views/profile_tab_view.dart';
import '../../subscriptions/viewmodels/subscriptions_booking_store.dart';
import '../../subscriptions/viewmodels/subscriptions_scope.dart';
import '../../subscriptions/views/subscriptions_tab_view.dart';
import '../../theme/customers_login_themeview.dart';
import '../../core/widgets/responsive_helper.dart';
import '../../complaints/viewmodels/complaints_viewmodel.dart';
import '../home_shell_scope.dart';
import '../widgets/added_to_cart_bar.dart';
import '../../rewards/viewmodels/rewards_viewmodel.dart';
import '../../rewards/views/rewards_view.dart';
import '../../core/services/haptic_service.dart';


class BottomNavigationView extends StatefulWidget {
  const BottomNavigationView({super.key});

  static ValueChanged<int>? onSelectTabGlobal;

  @override
  State<BottomNavigationView> createState() => _BottomNavigationViewState();
}

class _BottomNavigationViewState extends State<BottomNavigationView> {
  final CartViewModel _cartViewModel = CartViewModel();
  final SubscriptionsBookingStore _subscriptionsStore =
      SubscriptionsBookingStore();
  final ComplaintsViewModel _complaintsViewModel = ComplaintsViewModel();
  late final RewardsViewModel _rewardsViewModel =
      RewardsViewModel(cartViewModel: _cartViewModel);
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    BottomNavigationView.onSelectTabGlobal = (idx) {
      if (mounted) {
        _onTap(idx);
      }
    };
    AppRouteStorage.saveRoute('/home');
    _restoreTabIndex();
  }

  Future<void> _restoreTabIndex() async {
    final index = await AppRouteStorage.getHomeTabIndex();
    if (mounted) {
      setState(() => _currentIndex = index);
    }
  }

  void _onTap(int idx) {
    if (idx != _currentIndex) {
      HapticService.lightImpact();
    }
    setState(() => _currentIndex = idx);
    AppRouteStorage.saveHomeTabIndex(idx);
    if (idx == 1) {
      _cartViewModel.dismissAddedToCartBar();
    }
  }

  void _goToCart() {
    _cartViewModel.dismissAddedToCartBar();
    setState(() => _currentIndex = 1);
    AppRouteStorage.saveHomeTabIndex(1);
  }

  @override
  void dispose() {
    BottomNavigationView.onSelectTabGlobal = null;
    _cartViewModel.dispose();
    _subscriptionsStore.dispose();
    _complaintsViewModel.dispose();
    _rewardsViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fs = (double size) => ResponsiveHelper.scaledFontSize(context, size);
    final scaleF = (double val) => ResponsiveHelper.scaledValue(context, val);

    return CartScope(
      store: _cartViewModel,
      child: SubscriptionsScope(
        store: _subscriptionsStore,
        child: HomeShellScope(
        currentTabIndex: _currentIndex,
        onTabSelected: _onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_cartViewModel, _subscriptionsStore]),
          builder: (context, _) {
            final showBar = _cartViewModel.showAddedToCartBar &&
                _cartViewModel.items.isNotEmpty &&
                _currentIndex != 1;
            final cartCount = _cartViewModel.totalProductCount;
            final showSubBadge = _subscriptionsStore.hasBookings &&
                _subscriptionsStore.bookings.any((b) => !b.isFullyPaid);

            return Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  const HomeTabView(),
                  const CartTabView(),
                  const SubscriptionsTabView(),
                  RewardsView(viewModel: _rewardsViewModel),
                  ProfileTabView(complaintsViewModel: _complaintsViewModel),
                ],
              ),
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBar)
                    AddedToCartBar(
                      onViewCart: _goToCart,
                      onDismiss: _cartViewModel.dismissAddedToCartBar,
                    ),
                  BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: CustomersLoginThemeView.scaffoldBackgroundColor,
                    elevation: 0,
                    currentIndex: _currentIndex,
                    onTap: _onTap,
                    selectedItemColor: CustomersLoginThemeView.primaryBlue,
                    unselectedItemColor: CustomersLoginThemeView.textGrey,
                    selectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fs(11),
                    ),
                    unselectedLabelStyle: TextStyle(fontSize: fs(11)),
                    iconSize: scaleF(24).clamp(20.0, 28.0),
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: _cartNavIcon(
                          context,
                          fs,
                          outlined: true,
                          count: cartCount,
                        ),
                        activeIcon: _cartNavIcon(
                          context,
                          fs,
                          outlined: false,
                          count: cartCount,
                        ),
                        label: 'Cart',
                      ),
                      BottomNavigationBarItem(
                        icon: showSubBadge
                            ? const Badge(
                                child: Icon(Icons.inventory_2_outlined),
                              )
                            : const Icon(Icons.inventory_2_outlined),
                        activeIcon: showSubBadge
                            ? const Badge(
                                child: Icon(Icons.inventory_2),
                              )
                            : const Icon(Icons.inventory_2),
                        label: 'Subscription',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.card_giftcard_outlined),
                        activeIcon: Icon(Icons.redeem),
                        label: 'Rewards',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: Icon(Icons.person),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }

  Widget _cartNavIcon(
    BuildContext context,
    double Function(double) fs, {
    required bool outlined,
    required int count,
  }) {
    final icon = Icon(
      outlined ? Icons.shopping_cart_outlined : Icons.shopping_cart,
    );
    if (count <= 0) return icon;
    return Badge(
      isLabelVisible: true,
      label: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(fontSize: fs(10)),
      ),
      backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
      child: icon,
    );
  }
}
