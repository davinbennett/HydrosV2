import 'package:frontend/presentation/screens/login_screen.dart';
import 'package:frontend/presentation/screens/signup_screen.dart';
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
];
