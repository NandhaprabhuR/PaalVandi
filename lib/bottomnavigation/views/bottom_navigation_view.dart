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
import '../home_shell_scope.dart';
import '../widgets/added_to_cart_bar.dart';

class BottomNavigationView extends StatefulWidget {
  const BottomNavigationView({super.key});

  @override
  State<BottomNavigationView> createState() => _BottomNavigationViewState();
}

class _BottomNavigationViewState extends State<BottomNavigationView> {
  final CartViewModel _cartViewModel = CartViewModel();
  final SubscriptionsBookingStore _subscriptionsStore =
      SubscriptionsBookingStore();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
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
    _cartViewModel.dispose();
    _subscriptionsStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CartScope(
      store: _cartViewModel,
      child: SubscriptionsScope(
        store: _subscriptionsStore,
        child: HomeShellScope(
        currentTabIndex: _currentIndex,
        onTabSelected: _onTap,
        child: AnimatedBuilder(
          animation: _cartViewModel,
          builder: (context, _) {
            final showBar = _cartViewModel.showAddedToCartBar &&
                _cartViewModel.items.isNotEmpty &&
                _currentIndex != 1;
            final cartCount = _cartViewModel.totalProductCount;

            return Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: const [
                  HomeTabView(),
                  CartTabView(),
                  SubscriptionsTabView(),
                  ProfileTabView(),
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
                    currentIndex: _currentIndex,
                    onTap: _onTap,
                    selectedItemColor: CustomersLoginThemeView.primaryBlue,
                    unselectedItemColor: CustomersLoginThemeView.textGrey,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    unselectedLabelStyle: const TextStyle(fontSize: 11),
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: _cartNavIcon(
                          outlined: true,
                          count: cartCount,
                        ),
                        activeIcon: _cartNavIcon(
                          outlined: false,
                          count: cartCount,
                        ),
                        label: 'Cart',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.inventory_2_outlined),
                        activeIcon: Icon(Icons.inventory_2),
                        label: 'Subscription',
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

  Widget _cartNavIcon({required bool outlined, required int count}) {
    final icon = Icon(
      outlined ? Icons.shopping_cart_outlined : Icons.shopping_cart,
    );
    if (count <= 0) return icon;
    return Badge(
      isLabelVisible: true,
      label: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(fontSize: 10),
      ),
      backgroundColor: CustomersLoginThemeView.sectionHeadingRed,
      child: icon,
    );
  }
}
