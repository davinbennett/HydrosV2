import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'app_nav.dart';
import 'auth_nav.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}


final mainRouterProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final isSplash = state.name == 'splash';

      if (authStatus == AuthStatus.loading) {
        return isSplash ? null : '/splash';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ...authRoutes, 
      ...appRoutes
    ],
  );
});
