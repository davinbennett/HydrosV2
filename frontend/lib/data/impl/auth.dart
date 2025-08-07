import 'package:frontend/data/models/auth.dart';
import 'package:frontend/domain/repositories/auth.dart';
import 'package:frontend/infrastructure/api/auth_api.dart';

// ! NANTI DI CLASS LAIN, NGECEK : JIKA ADA INTERNET MAKA GET KE API, JIKA TIDAK MAKA GET KE LOCAL


class AuthImpl implements AuthRepository {
  final AuthApi api;

  AuthImpl(this.api);

  @override
  Future<LoginModel> loginWithEmail(String email, String password) {
    return api.loginWithEmail(email: email, password: password);
  }

  @override
  Future<LoginModel> loginWithGoogle(String idToken) {
    return api.loginWithGoogle(idToken: idToken);
  }
}
