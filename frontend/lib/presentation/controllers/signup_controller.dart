import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/auth/signup.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';

class SignupController extends StateNotifier<AuthStatus> {
  final SignupWithEmailUseCase signupEmailUsecase;
  final SignupWithGoogleUseCase signupGoogleUsecase;

  SignupController({
    required this.signupEmailUsecase,
    required this.signupGoogleUsecase,
  }) : super(AuthStatus.unauthenticated);

  Future<String?> signupEmail({
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
  }) async {
    state = AuthStatus.loading;

    try {
      final result = await signupEmailUsecase.execute(email, password, username, confirmPassword);

      await SecureStorage.saveAccessToken(result.accessToken);
      await SecureStorage.saveUserId(result.userId.toString());

      state = AuthStatus.authenticated;
      return null;
    } catch (e) {
      state = AuthStatus.unauthenticated;
      return e.toString().isNotEmpty ? e.toString() : 'Unknown error occurred.';
    }
  }

  Future<void> signupGoogle({required String googleId}) async {
    state = AuthStatus.loading;
    try {
      final result = await signupGoogleUsecase.execute(googleId);

      await SecureStorage.saveAccessToken(result.accessToken);
      await SecureStorage.saveUserId(result.userId as String);

      state = AuthStatus.authenticated;
    } catch (e) {
      state = AuthStatus.unauthenticated;
    }
  }
}
