import 'package:frontend/data/models/auth.dart';
import 'package:frontend/domain/repositories/auth.dart';

class SignupWithEmailUseCase {
  final AuthRepository repository;

  SignupWithEmailUseCase(this.repository);

  Future<SignupModel> execute(
    String email,
    String password,
    String username,
    String confirmPassword,
  ) {
    return repository.signupWithEmail(
      email,
      password,
      username,
      confirmPassword,
    );
  }
}

class SignupWithGoogleUseCase {
  final AuthRepository repository;

  SignupWithGoogleUseCase(this.repository);

  Future<SignupModel> execute(String idToken) {
    return repository.signupWithGoogle(idToken);
  }
}
