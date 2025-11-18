import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/impl/auth.dart';
import 'package:frontend/data/impl/device.dart';
import 'package:frontend/domain/repositories/auth.dart';
import 'package:frontend/domain/repositories/device.dart';
import 'package:frontend/domain/usecase/auth/login.dart';
import 'package:frontend/domain/usecase/auth/new_password.dart';
import 'package:frontend/domain/usecase/auth/register_with_email.dart';
import 'package:frontend/domain/usecase/auth/reset_password.dart';
import 'package:frontend/domain/usecase/auth/signup.dart';
import 'package:frontend/domain/usecase/auth/verify_otp.dart';
import 'package:frontend/domain/usecase/device/control_pump.dart';
import 'package:frontend/domain/usecase/device/pair_device.dart';
import 'package:frontend/infrastructure/api/auth_api.dart';
import 'package:frontend/infrastructure/api/device_api.dart';
import 'package:frontend/infrastructure/google_signin/auth.dart';
import 'package:frontend/presentation/controllers/login_controller.dart';
import 'package:frontend/presentation/controllers/new_password_controller.dart';
import 'package:frontend/presentation/controllers/pair_device_controller.dart';
import 'package:frontend/presentation/controllers/reset_password_controller.dart';
import 'package:frontend/presentation/controllers/signup_controller.dart';
import 'package:frontend/presentation/controllers/verify_otp_controller.dart';

import '../../data/impl/alarm.dart';
import '../../data/impl/pumplog.dart';
import '../../domain/repositories/alarm.dart';
import '../../domain/repositories/pumplog.dart';
import '../../domain/usecase/alarm.dart';
import '../../domain/usecase/pumplog.dart';
import '../../infrastructure/api/alarm_api.dart';
import '../../infrastructure/api/pumplog_api.dart';
import '../controllers/alarm_controller.dart';
import '../controllers/service_controller.dart';

// API & Firebase service
final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref);
});
final deviceApiProvider = Provider<DeviceApi>((ref) {
  return DeviceApi(ref);
});
final alarmApiProvider = Provider<AlarmApi>((ref) {
  return AlarmApi(ref);
});
final pumplogApiProvider = Provider<PumplogApi>((ref) {
  return PumplogApi(ref);
});

final firebaseServiceProvider = Provider<GoogleSigninAuthService>((ref) {
  return GoogleSigninAuthService();
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.read(authApiProvider);
  final firebase = ref.read(firebaseServiceProvider);
  return AuthImpl(api: api, firebaseService: firebase);
});
final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final api = ref.read(deviceApiProvider);
  return DeviceImpl(api: api);
});
final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  final api = ref.read(alarmApiProvider);
  return AlarmImpl(api: api);
});
final pumplogRepositoryProvider = Provider<PumplogRepository>((ref) {
  final api = ref.read(pumplogApiProvider);
  return PumpLogImpl(api: api);
});

// UseCase
final loginWithEmailUsecaseProvider = Provider<LoginWithEmailUseCase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return LoginWithEmailUseCase(repo);
});

final loginWithGoogleUsecaseProvider = Provider<LoginWithGoogleUseCase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return LoginWithGoogleUseCase(repo);
});

final signupWithEmailUsecaseProvider = Provider<SignupUseCase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return SignupUseCase(repo);
});

final verifyOtpUsecaseProvider = Provider<VerifyOtpUseCase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return VerifyOtpUseCase(repo);
});

final registerWithEmailUsecaseProvider = Provider<RegisterWithEmailUseCase>((
  ref,
) {
  final repo = ref.read(authRepositoryProvider);
  return RegisterWithEmailUseCase(repo);
});

final resetPasswordUsecaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return ResetPasswordUseCase(repo);
});

final newPasswordUsecaseProvider = Provider<NewPasswordUseCase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return NewPasswordUseCase(repo);
});

final pairDeviceUsecaseProvider = Provider<PairDeviceUsecase>((ref) {
  final repo = ref.read(deviceRepositoryProvider);
  return PairDeviceUsecase(repo);
});
final controlPumpUsecaseProvider = Provider<ControlPumpUsecase>((ref) {
  final repo = ref.read(deviceRepositoryProvider);
  return ControlPumpUsecase(repo);
});
final alarmUsecaseProvider = Provider<AlarmUsecase>((ref) {
  final repo = ref.read(alarmRepositoryProvider);
  return AlarmUsecase(repo);
});
final pumplogUsecaseProvider = Provider<PumplogUsecase>((ref) {
  final repo = ref.read(pumplogRepositoryProvider);
  return PumplogUsecase(repo);
});

// === controller ===
final loginControllerProvider = Provider<LoginController>((ref) {
  final usecaseLoginEmail = ref.read(loginWithEmailUsecaseProvider);
  final usecaseLoginGoogle = ref.read(loginWithGoogleUsecaseProvider);
  return LoginController(
    loginEmailUsecase: usecaseLoginEmail,
    loginGoogleUsecase: usecaseLoginGoogle,
  );
});

final signupControllerProvider = Provider<SignupController>((ref) {
  final usecaseSignupEmail = ref.read(signupWithEmailUsecaseProvider);
  return SignupController(signupUsecase: usecaseSignupEmail);
});

final verifyOtpControllerProvider = Provider<VerifyOtpController>((ref) {
  final usecaseVerifyOtp = ref.read(verifyOtpUsecaseProvider);
  return VerifyOtpController(verifyOtpUsecase: usecaseVerifyOtp);
});

final registerWithEmailControllerProvider =
    Provider<RegisterWithEmailController>((ref) {
      final usecaseRegisterWithEmail = ref.read(
        registerWithEmailUsecaseProvider,
      );
      return RegisterWithEmailController(
        registerWithEmailUsecase: usecaseRegisterWithEmail,
      );
    });

final resetPasswordControllerProvider = Provider<ResetPasswordController>((
  ref,
) {
  final usecaseResetPassword = ref.read(resetPasswordUsecaseProvider);
  return ResetPasswordController(resetPasswordUsecase: usecaseResetPassword);
});

final newPasswordControllerProvider = Provider<NewPasswordController>((ref) {
  final usecase = ref.read(newPasswordUsecaseProvider);
  return NewPasswordController(newPasswordUsecase: usecase);
});

final pairDeviceControllerProvider = Provider<PairDeviceController>((ref) {
  final usecase = ref.read(pairDeviceUsecaseProvider);
  return PairDeviceController(pairDeviceUsecase: usecase, ref: ref);
});

final serviceControllerProvider = Provider<ServiceController>((ref) {
  final usecase = ref.read(controlPumpUsecaseProvider);
  final alarmUsecase = ref.read(alarmUsecaseProvider);
  return ServiceController(
    alarmUsecase: alarmUsecase,
    controlPumpUsecase: usecase,
    pumplogUsecase: ref.read(pumplogUsecaseProvider),
    ref: ref,
  );
});

final alarmControllerProvider = Provider<AlarmController>((ref) {
  final alarmUsecase = ref.read(alarmUsecaseProvider);
  return AlarmController(
    alarmUsecase: alarmUsecase,
    ref: ref,
  );
});
