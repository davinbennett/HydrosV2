import 'package:frontend/domain/usecase/auth/new_password.dart';


class NewPasswordController {
  final NewPasswordUseCase newPasswordUsecase;

  NewPasswordController({required this.newPasswordUsecase});

  Future<String?> newPassword({
    required String email, 
    required String password,
  }) async {
    try {
      await newPasswordUsecase.execute(email, password);
      return null;
    } catch (e) {
      final message =
          e.toString().isNotEmpty
              ? e.toString()
              : 'Something went wrong.';
      return message;
    }
  }
}
