import 'package:frontend/domain/repositories/auth.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<String> execute(String email, String otp) {
    return repository.verifyOtp(email, otp);
  }
}
