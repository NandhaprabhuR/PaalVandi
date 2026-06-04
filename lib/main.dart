import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// ViewModels
import 'auth/viewmodels/auth_viewmodel.dart';
import 'home/viewmodels/home_viewmodel.dart';
import 'orders/viewmodels/orders_viewmodel.dart';
import 'subscriptions/viewmodels/subscriptions_viewmodel.dart';
import 'bulk_orders/viewmodels/bulk_viewmodel.dart';
import 'bottles/viewmodels/bottles_viewmodel.dart';
import 'profile/viewmodels/profile_viewmodel.dart';
import 'notifications/viewmodels/notification_viewmodel.dart';

// Views
import 'auth/views/login_view.dart';
import 'home/views/home_tab_view.dart';
import 'orders/views/daily_orders_view.dart';
import 'orders/views/order_detail_view.dart';
import 'orders/views/delivered_history_view.dart';
import 'subscriptions/views/subscriptions_view.dart';
import 'subscriptions/views/subscription_history_view.dart';
import 'subscriptions/views/subscription_billing_details_view.dart';
import 'subscriptions/views/subscription_monthly_history_view.dart';
import 'subscriptions/views/subscription_summary_report_view.dart';
import 'bulk_orders/views/bulk_orders_view.dart';
import 'bulk_orders/views/bulk_orders_history_view.dart';
import 'bottles/views/bottles_view.dart';
import 'bottles/views/bottles_history_view.dart';
import 'profile/views/profile_view.dart';
import 'route_map/views/route_map_view.dart';
import 'notifications/views/notifications_view.dart';

// Widgets & Themes
import 'core/widgets/bottom_nav_shell.dart';
import 'theme/paalvandi_theme.dart';

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
        builder: (context, state) => const LoginView(),
      ),
      ShellRoute(
        builder: (context, state, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeTabView(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const DailyOrdersView(),
          ),
          GoRoute(
            path: '/subscriptions',
            builder: (context, state) => const SubscriptionsView(),
          ),
          GoRoute(
            path: '/bulk-orders',
            builder: (context, state) => const BulkOrdersView(),
          ),
          GoRoute(
            path: '/bottles',
            builder: (context, state) => const BottlesView(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: '/order-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailView(orderId: id);
        },
      ),
      GoRoute(
        path: '/route-map',
        builder: (context, state) => const RouteMapView(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsView(),
      ),
      GoRoute(
        path: '/subscriptions/history',
        builder: (context, state) => const SubscriptionHistoryView(),
      ),
      GoRoute(
        path: '/subscriptions/billing-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SubscriptionBillingDetailsView(subscriptionId: id);
        },
      ),
      GoRoute(
        path: '/subscriptions/billing-history/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SubscriptionMonthlyHistoryView(subscriptionId: id);
        },
      ),
      GoRoute(
        path: '/subscriptions/billing-report',
        builder: (context, state) => const SubscriptionSummaryReportView(),
      ),
      GoRoute(
        path: '/orders/history',
        builder: (context, state) => const DeliveredHistoryView(),
      ),
      GoRoute(
        path: '/bulk-orders/history',
        builder: (context, state) => const BulkOrdersHistoryView(),
      ),
      GoRoute(
        path: '/bottles/history',
        builder: (context, state) => const BottlesHistoryView(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthViewModel>(
          create: (context) => AuthViewModel(),
        ),
        BlocProvider<HomeViewModel>(
          create: (context) => HomeViewModel(),
        ),
        BlocProvider<OrdersViewModel>(
          create: (context) => OrdersViewModel(),
        ),
        BlocProvider<SubscriptionsViewModel>(
          create: (context) => SubscriptionsViewModel(),
        ),
        BlocProvider<BulkViewModel>(
          create: (context) => BulkViewModel(),
        ),
        BlocProvider<BottlesViewModel>(
          create: (context) => BottlesViewModel(),
        ),
        BlocProvider<ProfileViewModel>(
          create: (context) => ProfileViewModel(),
        ),
        BlocProvider<NotificationViewModel>(
          create: (context) => NotificationViewModel(),
        ),
      ],
      child: MaterialApp.router(
        title: 'PaalVandi Partner',
        debugShowCheckedModeBanner: false,
        theme: PaalvandiTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
