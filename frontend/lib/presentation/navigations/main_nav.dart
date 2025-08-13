import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/providers/global_auth_provider.dart';
import 'package:frontend/presentation/screens/splash_screen.dart';
import 'package:frontend/presentation/states/global_auth_state.dart';
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
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      ref.watch(globalStateProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final globalState = ref.read(globalStateProvider);

      final isSplash = state.matchedLocation == '/splash';

      if (globalState is GlobalLoading || globalState is GlobalInitial) {
        return isSplash ? null : '/splash';
      }

      if (globalState is GlobalAuthenticated) {
        return isSplash ? '/home' : null;
      }

      if (globalState is GlobalUnauthenticated) {
        return isSplash ? '/login' : null;
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
