import 'package:frontend/data/models/auth.dart';

// ! HANYA KUMPULAN ABSTRACT
// ! PAKAI MODEL JIKA RESPONSENYA BEDA JAUH DENGAN ENTITIES

abstract class AuthRepository {
  Future<LoginModel> loginWithEmail(String email, String password);
  Future<LoginModel> loginWithGoogle();
  Future<String> signupWithEmail(String email);
}
