import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/states/global_auth_state.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


class SplashController extends StateNotifier<GlobalState> {
  SplashController() : super(GlobalInitial());

  Future<void> checkLogin() async {
    state = GlobalLoading();
    
    final accessToken = await SecureStorage.getAccessToken();
    final userId = await SecureStorage.getUserId();

    if (accessToken != null &&
        accessToken.isNotEmpty &&
        userId != null &&
        !JwtDecoder.isExpired(accessToken)) {
      state = GlobalAuthenticated();
    } else {
      state = GlobalUnauthenticated();
    }
  }
}
