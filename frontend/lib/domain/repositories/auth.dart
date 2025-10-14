
import 'package:frontend/domain/entities/auth.dart';

// ! HANYA KUMPULAN ABSTRACT
// ! PAKAI MODEL JIKA RESPONSENYA BEDA JAUH DENGAN ENTITIES

abstract class AuthRepository {
  Future<AuthEntity> loginWithEmail(String email, String password);
  Future<AuthEntity> loginWithGoogle();
  Future<String> requestOtp(String email, String isFrom);
  Future<String> verifyOtp(String email, String otp);
  Future<AuthEntity> registerWithEmail(
    String username,
    String email,
    String password,
  );
  Future<String> newPassword(String email, String password);

}
