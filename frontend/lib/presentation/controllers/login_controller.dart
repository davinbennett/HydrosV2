import 'package:frontend/domain/entities/auth.dart';
import 'package:frontend/domain/usecase/auth/login.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/states/auth_state.dart';
import 'package:uuid/uuid.dart';

class LoginController {
  final LoginWithEmailUseCase loginEmailUsecase;
  final LoginWithGoogleUseCase loginGoogleUsecase;

  LoginController({
    required this.loginEmailUsecase,
    required this.loginGoogleUsecase,
  }) : super();

  Future<AuthState> loginEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await loginEmailUsecase.execute(email, password);
      final uuid = const Uuid().v4();
      final appUid = 'app-$uuid';

      await SecureStorage.saveAccessToken(result.accessToken);
      await SecureStorage.saveUserId(result.userId);
      await SecureStorage.saveDeviceUId(appUid);


      final authenticated = AuthAuthenticated(result);

      return authenticated;
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }

  Future<AuthState> loginWithGoogle() async {
    try {
      final result = await loginGoogleUsecase.execute();
      final uuid = const Uuid().v4();
      final appUid = 'app-$uuid';

      await SecureStorage.saveAccessToken(result.accessToken);
      await SecureStorage.saveUserId(result.userId);
      await SecureStorage.saveDeviceUId(appUid);

      final authEntity = AuthEntity(
        userId: result.userId,
        accessToken: result.accessToken,
      );

      final authenticated = AuthAuthenticated(authEntity);

      return authenticated;
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }
}
