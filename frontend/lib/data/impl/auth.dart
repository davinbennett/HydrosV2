
import 'package:frontend/domain/entities/auth.dart';
import 'package:frontend/domain/repositories/auth.dart';
import 'package:frontend/infrastructure/api/auth_api.dart';
import 'package:frontend/infrastructure/google_signin/auth.dart';

// ! NANTI DI CLASS LAIN, NGECEK : JIKA ADA INTERNET MAKA GET KE API, JIKA TIDAK MAKA GET KE LOCAL

class AuthImpl implements AuthRepository {
  final AuthApi api;
  final GoogleSigninAuthService firebaseService;

  AuthImpl({required this.api, required this.firebaseService});


  @override
  Future<AuthEntity> loginWithEmail(String email, String password) async {
    final model = await api.loginWithEmail(email: email, password: password);
    return model.toEntity();
  }

  @override
  Future<AuthEntity> loginWithGoogle() async {
    // Sign-in Google Firebase
    final idToken = await firebaseService.signInWithGoogle();

    // Kirim idToken ke backend API
    final model = await api.loginWithGoogle(idToken: idToken);

    return model.toEntity();
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
  Future<AuthEntity> registerWithEmail(
    String username,
    String email,
    String password,
  ) async {
    final model = await api.registerWithEmail(
      username: username,
      email: email,
      password: password,
    );

    return model.toEntity();
  }

  @override
  Future<String> newPassword(String email, String password) {
    return api.newPassword(email: email, password: password);
  }
}
