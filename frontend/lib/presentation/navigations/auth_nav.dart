import 'package:frontend/presentation/screens/login_screen.dart';
import 'package:frontend/presentation/screens/signup_screen.dart';
import 'package:frontend/presentation/screens/verify_email_screen.dart';
import 'package:go_router/go_router.dart';

final authRoutes = <GoRoute>[
  GoRoute(
    name: 'login',
    path: '/login',
    builder: (context, state) => LoginScreen(),
  ),
  GoRoute(
    name: 'signup',
    path: '/signup',
    builder: (context, state) => SignUpScreen(),
  ),
  GoRoute(
    path: '/verify-email',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>;
      return VerifyEmailScreen(
        email: extra['email'],
        password: extra['password'],
        username: extra['username'],
      );
    },
  ),

];
