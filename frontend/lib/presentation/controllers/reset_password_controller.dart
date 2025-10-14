
import 'package:frontend/domain/usecase/auth/reset_password.dart';
import 'package:frontend/presentation/states/auth_state.dart';

class ResetPasswordController {
  final ResetPasswordUseCase resetPasswordUsecase;

  ResetPasswordController({required this.resetPasswordUsecase})
    : super();

  Future<AuthState> resetPassword({required String email}) async {
    try {
      await resetPasswordUsecase.execute(email);
      return AuthPasswordReset();
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }
}
