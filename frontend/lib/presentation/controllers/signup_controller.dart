import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/auth/register_with_email.dart';
import 'package:frontend/domain/usecase/auth/signup.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/states/signup_state.dart';

class SignupController extends StateNotifier<SignupState> {
  final SignupUseCase signupEmailUsecase;

  SignupController({required this.signupEmailUsecase}) : super(SignupInitial());

  Future<Map<String, String>?> signupEmail({
    required String email,
    String? password,
    String? username,
  }) async {
    state = SignupLoading(email: email,
      password: password,
      username: username,);

    try {
      await signupEmailUsecase.execute(email);

      state = SignupSuccess(email: email,
      password: password,
      username: username,);
    } catch (e) {
      state = SignupFailure(
        e.toString().isNotEmpty ? e.toString() : 'Unknown error occurred.',
        email: email,
        password: password,
        username: username,
      );
    }
    return null;
  }
}

class RegisterWithEmailController
    extends StateNotifier<RegisterWithEmailState> {
  final RegisterWithEmailUseCase registerWithEmailUsecase;

  RegisterWithEmailController({required this.registerWithEmailUsecase})
    : super(RegisterWithEmailInitial());

  Future<String?> registerWithEmail({
    required String username,
    required String email,
    required String password,
  }) async {
    state = RegisterWithEmailLoading();

    try {
      final result = await registerWithEmailUsecase.execute(
        username,
        email,
        password,
      );

      if (result.accessToken.isEmpty || result.userId == 0) {
        return null;
      }

      await SecureStorage.saveAccessToken(result.accessToken);
      await SecureStorage.saveUserId(result.userId.toString());

      state = RegisterWithEmailSuccess();
    } catch (e) {
      state = RegisterWithEmailFailure(
        e.toString().isNotEmpty ? e.toString() : 'Unknown error occurred.',
      );
    }
    return null;
  }
}
