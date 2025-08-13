import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/auth/login.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/states/login_state.dart';

class LoginController extends StateNotifier<LoginState> {
  final LoginWithEmailUseCase loginEmailUsecase;
  final LoginWithGoogleUseCase loginGoogleUsecase;

  LoginController({
    required this.loginEmailUsecase,
    required this.loginGoogleUsecase,
  }) : super(LoginInitial());

  Future<String?> loginEmail({
    required String email,
    required String password,
  }) async {
    state = LoginLoading();

    try {
      final result = await loginEmailUsecase.execute(email, password);

      await SecureStorage.saveAccessToken(result.accessToken);
      await SecureStorage.saveUserId(result.userId.toString());

      state = LoginSuccess();
    } catch (e) {
      state = LoginFailure(
        e.toString().isNotEmpty ? e.toString() : 'Unknown error occurred.',
      );
    }
    return null;
  }

  Future<String?> loginWithGoogle() async {
    state = LoginLoading();
    
    try {
      final result = await loginGoogleUsecase.execute();

      await SecureStorage.saveAccessToken(result.accessToken);
      await SecureStorage.saveUserId(result.userId.toString());

      state = LoginSuccess();
      return null;
    } catch (e) {
      state = LoginFailure(
        e.toString().isNotEmpty ? e.toString() : 'Unknown error occurred.',
      );
    }
    return null;
  }
}
