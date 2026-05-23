import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last main route and home bottom-nav tab across app restarts.
class AppRouteStorage {
  static const String _routeKey = 'last_route';
  static const String _homeTabKey = 'home_tab_index';

  static const Set<String> _persistentRoutes = {
    '/login',
    '/profile',
    '/home',
  };

  static Future<String> getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final route = prefs.getString(_routeKey);
    if (route != null && _persistentRoutes.contains(route)) {
      return route;
    }
    return '/login';
  }

  static Future<void> saveRoute(String route) async {
    if (!_persistentRoutes.contains(route)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_routeKey, route);
  }

  static Future<int> getHomeTabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_homeTabKey) ?? 0;
  }

  static Future<void> saveHomeTabIndex(int index) async {
    if (index < 0 || index > 3) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_homeTabKey, index);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_routeKey);
    await prefs.remove(_homeTabKey);
  }
}
