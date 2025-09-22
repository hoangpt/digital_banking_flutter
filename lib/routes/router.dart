import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/payments/presentation/payment_dashboard.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        // TODO: Check auth state, redirect if needed
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const PaymentDashboard(),
    ),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
  ],
);
