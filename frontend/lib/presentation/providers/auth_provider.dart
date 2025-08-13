import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/auth/login.dart';
import 'package:frontend/domain/usecase/auth/register_with_email.dart';
import 'package:frontend/domain/usecase/auth/signup.dart';
import 'package:frontend/domain/usecase/auth/verify_otp.dart';
import 'package:frontend/presentation/controllers/login_controller.dart';
import 'package:frontend/presentation/controllers/signup_controller.dart';
import 'package:frontend/presentation/controllers/verify_otp_controller.dart';
import 'package:frontend/presentation/providers/injection.dart';
import 'package:frontend/presentation/states/login_state.dart';
import 'package:frontend/presentation/states/signup_state.dart';
import 'package:frontend/presentation/states/verify_otp.dart';

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
      final authRepository = ref.read(authRepositoryProvider);

      return LoginController(
        loginEmailUsecase: LoginWithEmailUseCase(authRepository),
        loginGoogleUsecase: LoginWithGoogleUseCase(authRepository),
      );
    });

final signUpControllerProvider =
    StateNotifierProvider<SignupController, SignupState>((ref) {
      final authRepository = ref.read(authRepositoryProvider);

      return SignupController(
        signupEmailUsecase: SignupWithEmailUseCase(authRepository),
      );
    });

final verifyOtpControllerProvider =
    StateNotifierProvider<VerifyOtpController, VerifyOtpState>((ref) {
      final authRepository = ref.read(authRepositoryProvider);

      return VerifyOtpController(
        verifyOtpUsecase: VerifyOtpUseCase(authRepository),
      );
    });

final registerWithEmailControllerProvider =
    StateNotifierProvider<RegisterWithEmailController, RegisterWithEmailState>((ref) {
      final authRepository = ref.read(authRepositoryProvider);

      return RegisterWithEmailController(
        registerWithEmailUsecase: RegisterWithEmailUseCase(authRepository),
      );
    });
