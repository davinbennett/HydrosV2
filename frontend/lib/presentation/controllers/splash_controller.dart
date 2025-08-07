import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';


class SplashController extends StateNotifier<AuthStatus> {
  SplashController() : super(AuthStatus.loading);

  Future<void> checkLogin() async {
    final accessToken = await SecureStorage.getAccessToken();
    final userId = await SecureStorage.getUserId();

    if (accessToken != null && accessToken.isNotEmpty && userId != null) {
      state = AuthStatus.authenticated;
    } else {
      state = AuthStatus.unauthenticated;
    }
  }
}
