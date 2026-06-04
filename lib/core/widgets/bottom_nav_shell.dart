import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/paalvandi_theme.dart';
import '../services/haptic_service.dart';

/// Shared bottom navigation shell for the 6-tab delivery application.
class BottomNavShell extends StatelessWidget {
  final Widget child;

  const BottomNavShell({
    super.key,
    required this.child,
  });

  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/subscriptions')) return 2;
    if (location.startsWith('/bulk-orders')) return 3;
    if (location.startsWith('/bottles')) return 4;
    return 0; // Default is /home
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == _getSelectedIndex(context)) return;
    
    HapticService.light();

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/orders');
        break;
      case 2:
        context.go('/subscriptions');
        break;
      case 3:
        context.go('/bulk-orders');
        break;
      case 4:
        context.go('/bottles');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: PaalvandiTheme.cardWhite,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => _onItemTapped(context, index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: PaalvandiTheme.cardWhite,
              selectedItemColor: PaalvandiTheme.primaryBlue,
              unselectedItemColor: PaalvandiTheme.textMuted,
              selectedLabelStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              unselectedLabelStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home, color: PaalvandiTheme.primaryBlue),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2, color: PaalvandiTheme.primaryBlue),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.autorenew_outlined),
                  activeIcon: Icon(Icons.autorenew, color: PaalvandiTheme.primaryBlue),
                  label: 'Subs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_outlined),
                  activeIcon: Icon(Icons.business, color: PaalvandiTheme.primaryBlue),
                  label: 'Bulk',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.recycling_outlined),
                  activeIcon: Icon(Icons.recycling, color: PaalvandiTheme.primaryBlue),
                  label: 'Bottles',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
