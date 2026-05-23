import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_route_storage.dart';

extension AppNavigation on BuildContext {
  /// Navigates and saves the route so the app reopens on this screen.
  void goPersist(String location, {Object? extra}) {
    AppRouteStorage.saveRoute(location);
    go(location, extra: extra);
  }
}
