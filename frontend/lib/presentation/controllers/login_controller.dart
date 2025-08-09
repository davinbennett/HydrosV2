import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/auth/login.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';

class LoginController extends StateNotifier<AuthStatus> {
  final LoginWithEmailUseCase loginEmailUsecase;
  final LoginWithGoogleUseCase loginGoogleUsecase;

  LoginController({
    required this.loginEmailUsecase,
    required this.loginGoogleUsecase,
  }) : super(AuthStatus.unauthenticated);

  Future<String?> loginEmail({
    required String email,
    required String password,
  }) async {
    state = AuthStatus.loading;

    try {
      final result = await loginEmailUsecase.execute(email, password);

      await SecureStorage.saveAccessToken(result.accessToken);
      await SecureStorage.saveUserId(result.userId.toString());

      state = AuthStatus.authenticated;
      return null;
    } catch (e) {
      state = AuthStatus.unauthenticated;
      return e.toString().isNotEmpty ? e.toString() : 'Unknown error occurred.';
    }
  }

  Future<String?> loginWithGoogle() async {
    state = AuthStatus.loading;
    
    try {
      final result = await loginGoogleUsecase.execute();

      await SecureStorage.saveAccessToken(result.accessToken);
      await SecureStorage.saveUserId(result.userId.toString());

      state = AuthStatus.authenticated;
      return null;
    } catch (e) {
      state = AuthStatus.unauthenticated;
      return e.toString().isNotEmpty ? e.toString() : 'Unknown error occurred.';
    }
  }

}
