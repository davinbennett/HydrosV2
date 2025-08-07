import 'package:frontend/presentation/screens/login_screen.dart';
import 'package:go_router/go_router.dart';

final authRoutes = <GoRoute>[
  GoRoute(
    name: 'login',
    path: '/login',
    builder: (context, state) => LoginScreen(),
  ),
];
