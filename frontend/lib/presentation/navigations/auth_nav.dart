import 'package:frontend/presentation/screens/login_screen.dart';
import 'package:frontend/presentation/screens/signup_screen.dart';
import 'package:frontend/presentation/screens/success_signup_screen.dart';
import 'package:frontend/presentation/screens/verify_otp_screen.dart';
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
    path: '/verify-otp',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>;
      return VerifyOtpScreen(
        email: extra['email'],
        password: extra['password'],
        username: extra['username'],
      );
    },
  ),
  GoRoute(
    name: 'success-signup',
    path: '/success-signup',
    builder: (context, state) => SuccessSignUpScreen(),
  ),

];
