import 'package:frontend/data/models/auth.dart';
import 'package:frontend/domain/repositories/auth.dart';
import 'package:frontend/infrastructure/api/auth_api.dart';
import 'package:frontend/infrastructure/google_signin/auth.dart';

// ! NANTI DI CLASS LAIN, NGECEK : JIKA ADA INTERNET MAKA GET KE API, JIKA TIDAK MAKA GET KE LOCAL

class AuthImpl implements AuthRepository {
  final AuthApi api;
  final GoogleSigninAuthService firebaseService;

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
  Future<String> requestOtp(
    String email,
    String isFrom,
  ) {
    return api.requestOtp(email: email, isFrom: isFrom);
  }

  @override
  Future<String> verifyOtp(
    String email,
    String otp,
  ) {
    return api.verifyOtp(email: email, otp: otp);
  }

  @override
  Future<LoginModel> registerWithEmail(String username, String email, String password) {
    return api.registerWithEmail(username: username, email: email, password: password);
  }

  @override
  Future<String> newPassword(String email, String password) {
    return api.newPassword(email: email, password: password);
  }
}
