import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/auth/new_password.dart';
import 'package:frontend/presentation/states/new_password_state.dart.dart';


class NewPasswordController extends StateNotifier<NewPasswordState> {
  final NewPasswordUseCase newPasswordUsecase;

  NewPasswordController({required this.newPasswordUsecase})
    : super(NewPasswordInitial());

  Future<String?> newPassword({required String email, required String password,
  }) async {
    state = NewPasswordLoading(
      email: email,
      password: password,
    );

    try {
      await newPasswordUsecase.execute(email, password);
      state = NewPasswordSuccess(
        email: email,
        password: password,
      );
    } catch (e) {
      state = NewPasswordFailure(
        e.toString().isNotEmpty ? e.toString() : 'Unknown error occurred.',
        email: email,
        password: password,
      );
    }
    return null;
  }
}
