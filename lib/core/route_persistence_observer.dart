import 'package:flutter/material.dart';
import 'app_route_storage.dart';

/// Keeps [AppRouteStorage] in sync when routes change via the navigator.
class RoutePersistenceObserver extends NavigatorObserver {
  void _persist(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || !name.startsWith('/')) return;
    AppRouteStorage.saveRoute(name);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _persist(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _persist(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _persist(newRoute);
  }
}
