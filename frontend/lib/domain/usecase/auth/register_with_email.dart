
import 'package:frontend/domain/entities/auth.dart';
import 'package:frontend/domain/repositories/auth.dart';

class RegisterWithEmailUseCase {
  final AuthRepository repository;

  RegisterWithEmailUseCase(this.repository);

  Future<AuthEntity> execute(String username, String email, String password) {
    return repository.registerWithEmail(username, email, password);
  }
}
