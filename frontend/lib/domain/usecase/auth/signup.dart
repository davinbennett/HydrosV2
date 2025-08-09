import 'package:frontend/domain/repositories/auth.dart';

class SignupWithEmailUseCase {
  final AuthRepository repository;

  SignupWithEmailUseCase(this.repository);

  Future<String> execute(
    String email,
  ) {
    return repository.signupWithEmail(
      email,
    );
  }
}