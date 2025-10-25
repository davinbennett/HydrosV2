import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/screens/editprof_screen.dart';
import 'package:go_router/go_router.dart';
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
    initialLocation: '/editprofile',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final isSplash = state.name == 'editprofile';

      if (authStatus == AuthStatus.loading) {
        return isSplash ? null : '/editprofile';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/editprofile',
        name: 'editprofile',
        builder: (context, state) => const EditProfilePage (),
      ),
    ],
  );
});
