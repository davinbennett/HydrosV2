
import 'package:frontend/domain/usecase/auth/verify_otp.dart';
import 'package:frontend/presentation/states/auth_state.dart';

class VerifyOtpController {
  final VerifyOtpUseCase verifyOtpUsecase;

  VerifyOtpController({required this.verifyOtpUsecase})
    : super();

  Future<AuthState> verifyOtp({required String email, required String otp}) async {
    try {
      await verifyOtpUsecase.execute(email, otp);

      return AuthOtpVerified();
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }
}
