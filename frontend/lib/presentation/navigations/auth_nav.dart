import 'package:frontend/presentation/screens/help_screen.dart';
import 'package:go_router/go_router.dart';

final authRoutes = <GoRoute>[
  GoRoute(
    name: 'help',
    path: '/help',
    builder: (context, state) => const HelpAboutPairDevicePage(),
  ),
  GoRoute(
    name: 'help',
    path: '/help',
    builder: (context, state) => const HelpAboutPairDevicePage(),
  ),
  // Add more auth/login/register routes here
];
