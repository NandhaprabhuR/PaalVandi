import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Themes
import 'theme/delivery_theme.dart';

// BLoC ViewModels
import 'auth/viewmodels/delivery_auth_viewmodel.dart';
import 'home/viewmodels/delivery_home_viewmodel.dart';

// Views
import 'auth/views/delivery_login_view.dart';
import 'home/views/delivery_home_view.dart';
import 'home/views/delivery_order_detail_view.dart';
import 'earnings/views/delivery_earnings_view.dart';
import 'profile/views/delivery_profile_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DeliveryPartnerApp());
}

class DeliveryPartnerApp extends StatelessWidget {
  const DeliveryPartnerApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const DeliveryLoginView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DeliveryHomeView(),
      ),
      GoRoute(
        path: '/order-detail',
        builder: (context, state) => const DeliveryOrderDetailView(),
      ),
      GoRoute(
        path: '/earnings',
        builder: (context, state) => const DeliveryEarningsView(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const DeliveryProfileView(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DeliveryAuthViewModel>(
          create: (context) => DeliveryAuthViewModel(),
        ),
        BlocProvider<DeliveryHomeViewModel>(
          create: (context) => DeliveryHomeViewModel(),
        ),
      ],
      child: MaterialApp.router(
        title: 'PaalVandi Partners',
        debugShowCheckedModeBanner: false,
        theme: DeliveryTheme.darkTheme,
        routerConfig: _router,
      ),
    );
  }
}
