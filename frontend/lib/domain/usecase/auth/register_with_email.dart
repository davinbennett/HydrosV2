import 'package:frontend/data/models/auth.dart';
import 'package:frontend/domain/repositories/auth.dart';

class RegisterWithEmailUseCase {
  final AuthRepository repository;

  RegisterWithEmailUseCase(this.repository);

  Future<LoginModel> execute(String username, String email, String password) {
    return repository.registerWithEmail(username, email, password);
  }
}
