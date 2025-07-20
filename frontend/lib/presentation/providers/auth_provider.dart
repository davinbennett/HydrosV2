import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

final authProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((ref) {
  return AuthNotifier()..checkAuth();
});

class AuthNotifier extends StateNotifier<AuthStatus> {
  AuthNotifier() : super(AuthStatus.loading);

  Future<void> checkAuth() async {
    final token = await SecureStorage.getAccessToken();
    final userId = await SecureStorage.getUserId();

    if (token != null && token.isNotEmpty && userId != null) {
      state = AuthStatus.authenticated;
    } else {
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> login({required String token, required String userId}) async {
    await SecureStorage.saveAccessToken(token);
    await SecureStorage.saveUserId(userId);
    state = AuthStatus.authenticated;
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
    state = AuthStatus.unauthenticated;
  }
}
