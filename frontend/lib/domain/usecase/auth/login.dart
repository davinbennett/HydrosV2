import 'package:frontend/domain/entities/auth.dart';
import 'package:frontend/domain/repositories/auth.dart';

class LoginWithEmailUseCase {
  final AuthRepository repository;
  LoginWithEmailUseCase(this.repository);

  Future<AuthEntity> execute(String email, String password) {
    return repository.loginWithEmail(email, password);
  }
}

class LoginWithGoogleUseCase {
  final AuthRepository repository;
  LoginWithGoogleUseCase(this.repository);

  Future<AuthEntity> execute() {
    return repository.loginWithGoogle();
  }
}
