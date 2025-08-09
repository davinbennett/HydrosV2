import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<String> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(clientId: dotenv.env['WEB_CLIENT_ID']);

      final account = await _googleSignIn.authenticate();

      final googleAuth = account.authentication;
      // final credential = GoogleAuthProvider.credential(
      //   idToken: googleAuth.idToken,
      // );
      // final userCredential = await FirebaseAuth.instance.signInWithCredential(
      //   credential,
      // );

      // final idToken = await userCredential.user?.getIdToken();
      // if (idToken == null) {
      //   throw 'Failed to retrieve Google ID token.';
      // }

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
