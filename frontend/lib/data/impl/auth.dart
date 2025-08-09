import 'package:frontend/data/models/auth.dart';
import 'package:frontend/domain/repositories/auth.dart';
import 'package:frontend/infrastructure/api/auth_api.dart';
import 'package:frontend/infrastructure/firebase/auth.dart';

// ! NANTI DI CLASS LAIN, NGECEK : JIKA ADA INTERNET MAKA GET KE API, JIKA TIDAK MAKA GET KE LOCAL

class AuthImpl implements AuthRepository {
  final AuthApi api;
  final FirebaseAuthService firebaseService;

  AuthImpl({required this.api, required this.firebaseService});


  @override
  Future<LoginModel> loginWithEmail(String email, String password) {
    return api.loginWithEmail(email: email, password: password);
  }

  @override
  Future<LoginModel> loginWithGoogle() async {
    // 1) firebase sign-in -> idToken
    final idToken = await firebaseService.signInWithGoogle();

    // 2) send idToken to backend
    final login = await api.loginWithGoogle(idToken: idToken);

    return login;
  }

  @override
  Future<SignupModel> signupWithEmail(
    String email,
    String password,
    String username,
    String confirmPassword,
  ) {
    return api.signupWithEmail(email: email, password: password);
  }

  @override
  Future<SignupModel> signupWithGoogle(String idToken) {
    return api.signupWithGoogle(idToken: idToken);
  }
}
