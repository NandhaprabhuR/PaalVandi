import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// ViewModels
import 'auth/viewmodels/customers_login_viewmodel.dart';
import 'auth/views/customers_login_view.dart';

import 'otp/viewmodels/customers_otp_viewmodel.dart';
import 'otp/views/customers_otp_view.dart';
import 'profile/viewmodels/customers_profile_viewmodel.dart';
import 'profile/views/customers_profile_view.dart';
import 'home/viewmodels/customers_home_viewmodel.dart';
import 'bottomnavigation/views/bottom_navigation_view.dart';
import 'core/app_route_storage.dart';
import 'core/route_persistence_observer.dart';
import 'theme/customers_login_themeview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PaalvandiApp());
}

CustomTransitionPage buildPageWithFadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

/// Loads persisted route first so hot reload never sees a null initial location.
class PaalvandiApp extends StatefulWidget {
  const PaalvandiApp({super.key});

  @override
  State<PaalvandiApp> createState() => _PaalvandiAppState();
}

class _PaalvandiAppState extends State<PaalvandiApp> {
  late final Future<String> _initialRouteFuture;

  @override
  void initState() {
    super.initState();
    _initialRouteFuture = AppRouteStorage.getInitialRoute();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialRouteFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              final mediaQueryData = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQueryData.copyWith(
                  textScaler: mediaQueryData.textScaler.clamp(
                    minScaleFactor: 0.8,
                    maxScaleFactor: 1.15,
                  ),
                ),
                child: child!,
              );
            },
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: const CircularProgressIndicator(
                  color: CustomersLoginThemeView.primaryBlue,
                ),
              ),
            ),
          );
        }

        return _PaalvandiRouterApp(initialLocation: snapshot.data!);
      },
    );
  }
}

class _PaalvandiRouterApp extends StatelessWidget {
  final String initialLocation;

  const _PaalvandiRouterApp({required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: initialLocation,
      observers: [RoutePersistenceObserver()],
      routes: [
        GoRoute(
          path: '/login',
          name: '/login',
          pageBuilder: (context, state) => buildPageWithFadeTransition(
            context: context,
            state: state,
            child: const CustomersLoginView(),
          ),
        ),
        GoRoute(
          path: '/otp',
          pageBuilder: (context, state) {
            final phoneNumber = state.extra as String? ?? '';
            return buildPageWithFadeTransition(
              context: context,
              state: state,
              child: CustomersOtpView(phoneNumber: phoneNumber),
            );
          },
        ),
        GoRoute(
          path: '/profile',
          name: '/profile',
          pageBuilder: (context, state) => buildPageWithFadeTransition(
            context: context,
            state: state,
            child: const CustomersProfileView(),
          ),
        ),
        GoRoute(
          path: '/home',
          name: '/home',
          pageBuilder: (context, state) => buildPageWithFadeTransition(
            context: context,
            state: state,
            child: const BottomNavigationView(),
          ),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CustomersLoginViewModel(null)),
        BlocProvider(create: (_) => CustomersOtpViewModel(null)),
        BlocProvider(create: (_) => CustomersProfileViewModel(null)),
        BlocProvider(create: (_) => CustomersHomeViewModel(null)..add(LoadHomeData())),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: CustomersLoginThemeView.themeModeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp.router(
            title: 'Paalvandi Customers',
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
            ),
            themeMode: themeMode,
            builder: (context, child) {
              final mediaQueryData = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQueryData.copyWith(
                  textScaler: mediaQueryData.textScaler.clamp(
                    minScaleFactor: 0.8,
                    maxScaleFactor: 1.15,
                  ),
                ),
                child: child!,
              );
            },
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
