import 'package:frontend/domain/repositories/auth.dart';

class NewPasswordUseCase {
  final AuthRepository repository;

  NewPasswordUseCase(this.repository);

  Future<String> execute(
    String email,
    String password,
  ) {
    return repository.newPassword(
      email,
      password,
    );
  }
}