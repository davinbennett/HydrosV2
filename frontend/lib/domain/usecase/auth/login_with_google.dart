import 'package:frontend/data/models/auth.dart';
import 'package:frontend/domain/repositories/auth.dart';

class LoginWithGoogleUseCase {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  Future<LoginModel> execute(String idToken) {
    return repository.loginWithGoogle(idToken);
  }
}
