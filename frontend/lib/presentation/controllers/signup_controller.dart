import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/auth/signup.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';

class SignupController extends StateNotifier<AuthStatus> {
  final SignupWithEmailUseCase signupEmailUsecase;
  
  SignupController({
    required this.signupEmailUsecase,
  }) : super(AuthStatus.unauthenticated);

  Future<String?> signupEmail({
    required String email,
  }) async {
    state = AuthStatus.loading;

    try {
      await signupEmailUsecase.execute(email);

      state = AuthStatus.authenticated;
      return null;
    } catch (e) {
      state = AuthStatus.unauthenticated;
      return e.toString().isNotEmpty ? e.toString() : 'Unknown error occurred.';
    }
  }
}
