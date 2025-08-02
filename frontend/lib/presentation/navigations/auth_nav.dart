import 'package:frontend/presentation/screens/home_screen.dart';
import 'package:frontend/presentation/screens/login_screen.dart';
import 'package:go_router/go_router.dart';

final authRoutes = <GoRoute>[
  GoRoute(
    name: 'login',
    path: '/login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    name: 'home',
    path: '/home',
    builder: (context, state) => const HomeScreen(),
  ),
  // Add more auth/login/register routes here
];
