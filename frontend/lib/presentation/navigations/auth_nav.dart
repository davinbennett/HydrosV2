import 'package:frontend/presentation/screens/login_screen.dart';
import 'package:frontend/presentation/screens/testing_screen.dart';
import 'package:go_router/go_router.dart';

final authRoutes = <GoRoute>[
  GoRoute(
    name: 'login',
    path: '/login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    name: 'tes',
    path: '/tes',
    builder: (context, state) => const TestingScreen(),
  ),
];
