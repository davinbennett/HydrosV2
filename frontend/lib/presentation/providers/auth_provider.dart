import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/entities/auth.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/states/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>(
  (ref) {
    return AuthNotifier()..checkLogin();
  },
);

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthNotifier() : super(const AsyncValue.loading());

  Future<void> checkLogin() async {
    try {
      state = const AsyncValue.loading();
      await Future.delayed(const Duration(milliseconds: 300));

      final accessToken = await SecureStorage.getAccessToken();
      final userId = await SecureStorage.getUserId();

      if (accessToken != null && userId != null) {
        final auth = AuthEntity(userId: userId, accessToken: accessToken);
        state = AsyncValue.data(AuthAuthenticated(auth));
      } else {
        state = AsyncValue.data(AuthUnauthenticated());
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = AsyncValue.data(AuthUnauthenticated());
  }

  void setAuthenticated(AsyncValue<AuthState> auth) {
    state = auth;
  }

  void setUnauthenticated() {
    state = AsyncValue.data(AuthUnauthenticated());
  }

  void setSessionExpired() { 
    state = AsyncValue.data(AuthSessionExpired());
  }
}
