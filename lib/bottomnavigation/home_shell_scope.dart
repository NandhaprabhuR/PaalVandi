import 'package:flutter/material.dart';

class HomeShellScope extends InheritedWidget {
  final int currentTabIndex;
  final ValueChanged<int> onTabSelected;

  const HomeShellScope({
    super.key,
    required this.currentTabIndex,
    required this.onTabSelected,
    required super.child,
  });

  static HomeShellScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HomeShellScope>();
    assert(scope != null, 'HomeShellScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(HomeShellScope oldWidget) =>
      currentTabIndex != oldWidget.currentTabIndex;
}
