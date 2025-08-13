import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/auth/verify_otp.dart';
import 'package:frontend/presentation/states/verify_otp.dart';

class VerifyOtpController extends StateNotifier<VerifyOtpState> {
  final VerifyOtpUseCase verifyOtpUsecase;

  VerifyOtpController({required this.verifyOtpUsecase}) : super(VerifyOtpInitial());

  Future<String?> verifyOtp({required String email, required String otp}) async {
    state = VerifyOtpLoading();

    try {
      await verifyOtpUsecase.execute(email, otp);

      state = VerifyOtpSuccess();
      return null;
    } catch (e) {
      state = VerifyOtpFailure(
        e.toString().isNotEmpty ? e.toString() : 'Unknown error occurred.',
      );
    }
    return null;
  }
}
