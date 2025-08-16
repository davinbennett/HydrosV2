import 'package:frontend/presentation/screens/create_new_password_screen.dart';
import 'package:frontend/presentation/screens/login_screen.dart';
import 'package:frontend/presentation/screens/reset_password_screen.dart';
import 'package:frontend/presentation/screens/signup_screen.dart';
import 'package:frontend/presentation/screens/success_signup_screen.dart';
import 'package:frontend/presentation/screens/success_update_password_screen.dart';
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
        previousScreen: extra['previousScreen'],
      );
    },
  ),
  GoRoute(
    name: 'success-signup',
    path: '/success-signup',
    builder: (context, state) => SuccessSignUpScreen(),
  ),
  GoRoute(
    name: 'reset-password',
    path: '/reset-password',
    builder: (context, state) => ResetPasswordScreen(),
  ),
  GoRoute(
    name: 'create-new-password',
    path: '/create-new-password',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      final email = extra?['email'] as String? ?? '';
      return CreateNewPasswordScreen(email: email);
    },
  ),
  GoRoute(
    name: 'success-update-password',
    path: '/success-update-password',
    builder: (context, state) => SuccessUpdatePasswordScreen(),
  ),

];
