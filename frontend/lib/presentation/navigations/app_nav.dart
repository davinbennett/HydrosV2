import 'package:frontend/presentation/screens/home_screen.dart';
import 'package:go_router/go_router.dart';

final appRoutes = <GoRoute>[
  GoRoute(
    name: 'home',
    path: '/home',
    builder: (context, state) => HomeScreen(),
  ),
];
