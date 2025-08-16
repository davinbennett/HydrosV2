import 'package:frontend/domain/repositories/auth.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<String> execute(
    String email,
  ) {
    return repository.requestOtp(
      email,
      'reset_password',
    );
  }
}