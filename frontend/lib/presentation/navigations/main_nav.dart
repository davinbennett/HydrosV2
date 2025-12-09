import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/screens/splash_screen.dart';
import 'package:frontend/presentation/states/auth_state.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import 'app_nav.dart';
import 'auth_nav.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(Ref ref) {
    // listen perubahan authProvider
    ref.listen<AsyncValue<AuthState>>(authProvider, (_, _) {
      notifyListeners();
    });
  }
}


final mainRouterProvider = Provider<GoRouter>((ref) {
  // final authNotifier = ref.watch(authProvider.notifier);
  
  final refreshNotifier = AuthChangeNotifier(ref);
  
  return GoRouter(
    observers: [routeObserver],
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,

    redirect: (context, state) {

      final authState = ref.read(authProvider);
      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';
      final isSignup = state.matchedLocation == '/signup';

      if (authState.isLoading) {
        return isSplash ? null : '/splash';
      }

      final data = authState.valueOrNull;

      // Jika belum login
      if (data is AuthUnauthenticated) {
        if (isSplash || isLogin || isSignup) return null;
        return '/login';
      }

      // Jika sudah login
      if (data is AuthAuthenticated) {
        if (isSplash || isLogin || isSignup) {
          return '/home';
        }
        return null;
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
