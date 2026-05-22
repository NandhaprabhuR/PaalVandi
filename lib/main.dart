import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// ViewModels
import 'auth/customers_login_viewmodel.dart';
import 'auth/customers_login_view.dart';
import 'otp/customers_otp_viewmodel.dart';
import 'otp/customers_otp_view.dart';
import 'profile/customers_profile_viewmodel.dart';
import 'profile/customers_profile_view.dart';
import 'home/customers_home_viewmodel.dart';
import 'home/customers_home_view.dart';

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

class PaalvandiApp extends StatelessWidget {
  const PaalvandiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
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
          pageBuilder: (context, state) => buildPageWithFadeTransition(
            context: context,
            state: state,
            child: const CustomersProfileView(),
          ),
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => buildPageWithFadeTransition(
            context: context,
            state: state,
            child: const CustomersHomeView(),
          ),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CustomersLoginViewModel(null)), // Pass null for mocked Supabase
        BlocProvider(create: (_) => CustomersOtpViewModel(null)),
        BlocProvider(create: (_) => CustomersProfileViewModel(null)),
        BlocProvider(create: (_) => CustomersHomeViewModel(null)..add(LoadHomeData())),
      ],
      child: MaterialApp.router(
        title: 'Paalvandi Customers',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
