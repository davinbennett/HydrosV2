import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/auth/reset_password.dart';
import 'package:frontend/presentation/states/reset_password_state.dart';

class ResetPasswordController extends StateNotifier<ResetPasswordState> {
  final ResetPasswordUseCase resetPasswordUsecase;

  ResetPasswordController({required this.resetPasswordUsecase})
    : super(ResetPasswordInitial());

  Future<String?> resetPassword({required String email}) async {
    state = ResetPasswordLoading(
      email: email,
      previousScreen: 'reset-password',
    );

    try {
      await resetPasswordUsecase.execute(email);
      state = ResetPasswordSuccess(
        email: email,
        previousScreen: 'reset-password',
      );
    } catch (e) {
      state = ResetPasswordFailure(
        e.toString().isNotEmpty ? e.toString() : 'Unknown error occurred.',
        email: email,
        previousScreen: 'reset-password',
      );
    }
    return null;
  }
}
