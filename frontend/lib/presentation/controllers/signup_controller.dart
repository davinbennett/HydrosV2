
import 'package:frontend/domain/usecase/auth/register_with_email.dart';
import 'package:frontend/domain/usecase/auth/signup.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/states/auth_state.dart';
import 'package:uuid/uuid.dart';

class SignupController {
  final SignupUseCase signupUsecase;

  SignupController({required this.signupUsecase})
    : super();

  Future<AuthState> signupEmail({required String email}) async {
    try {
      await signupUsecase.execute(email);

      return AuthSignupSuccess();
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }
}

class RegisterWithEmailController {
  final RegisterWithEmailUseCase registerWithEmailUsecase;

  RegisterWithEmailController({required this.registerWithEmailUsecase})
    : super();

  Future<AuthState> registerWithEmail({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final result = await registerWithEmailUsecase.execute(
        username,
        email,
        password,
      );

      if (result.accessToken.isEmpty || result.userId == '0') {
        return AuthFailure('Invalid access token or user ID');
      }

      final uuid = const Uuid().v4();
      final appUid = 'app-$uuid';

      await SecureStorage.saveAccessToken(result.accessToken);
      await SecureStorage.saveUserId(result.userId.toString());
      await SecureStorage.saveDeviceUId(appUid);

      return AuthAuthenticated(result);
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }
}