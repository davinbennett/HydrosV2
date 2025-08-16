import 'package:frontend/domain/repositories/auth.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<String> execute(
    String email,
  ) {
    return repository.requestOtp(
      email,
      'signup',
    );
  }
}