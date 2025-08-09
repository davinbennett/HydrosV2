import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSigninAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<String> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(clientId: dotenv.env['WEB_CLIENT_ID']);

      final account = await _googleSignIn.authenticate();

      final googleAuth = account.authentication;

      final idToken = googleAuth.idToken as String;

      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw 'Continue with Google cancelled.';
      } else {
        throw e.description as String;
      }
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
