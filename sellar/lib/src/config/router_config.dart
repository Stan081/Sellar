import 'package:go_router/go_router.dart';
import 'package:sellar/src/features/main/main_screen.dart';
import 'package:sellar/src/features/auth/presentation/welcome_screen.dart';
import 'package:sellar/src/features/auth/presentation/register_screen.dart';
import 'package:sellar/src/features/auth/presentation/business_profile_screen.dart';
import 'package:sellar/src/features/auth/presentation/login_screen.dart';

/// Application router configuration
class AppRouter {
  static GoRouter router = GoRouter(
    routes: [
      // Auth routes
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/business-profile',
        builder: (context, state) {
          final credentials = state.extra as Map<String, dynamic>?;
          if (credentials == null) {
            return const RegisterScreen();
          }
          return BusinessProfileScreen(credentials: credentials);
        },
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Main app
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
    ],
    initialLocation: '/welcome',
  );
}
