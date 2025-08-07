import 'package:frontend/data/models/auth.dart';
import 'package:frontend/domain/repositories/auth.dart';

class LoginWithEmailUseCase {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  Future<LoginModel> execute(String email, String password) {
    return repository.loginWithEmail(email, password);
  }
}
