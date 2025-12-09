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
import 'package:frontend/presentation/controllers/history_controller.dart';
import 'package:frontend/presentation/controllers/login_controller.dart';
import 'package:frontend/presentation/controllers/new_password_controller.dart';
import 'package:frontend/presentation/controllers/pair_device_controller.dart';
import 'package:frontend/presentation/controllers/reset_password_controller.dart';
import 'package:frontend/presentation/controllers/signup_controller.dart';
import 'package:frontend/presentation/controllers/verify_otp_controller.dart';

import '../../data/impl/ai.dart';
import '../../data/impl/alarm.dart';
import '../../data/impl/fcm.dart';
import '../../data/impl/notification.dart';
import '../../data/impl/profile.dart';
import '../../data/impl/pumplog.dart';
import '../../data/impl/sensor_aggregated.dart';
import '../../domain/repositories/ai.dart';
import '../../domain/repositories/alarm.dart';
import '../../domain/repositories/fcm.dart';
import '../../domain/repositories/notification.dart';
import '../../domain/repositories/profile.dart';
import '../../domain/repositories/pumplog.dart';
import '../../domain/repositories/sensor.dart';
import '../../domain/usecase/ai.dart';
import '../../domain/usecase/alarm.dart';
import '../../domain/usecase/device/device.dart';
import '../../domain/usecase/fcm.dart';
import '../../domain/usecase/notification.dart';
import '../../domain/usecase/profile.dart';
import '../../domain/usecase/pumplog.dart';
import '../../domain/usecase/sensor_aggregated.dart';
import '../../infrastructure/api/ai_api.dart';
import '../../infrastructure/api/alarm_api.dart';
import '../../infrastructure/api/fcm_api.dart';
import '../../infrastructure/api/notification_api.dart';
import '../../infrastructure/api/profile_api.dart';
import '../../infrastructure/api/pumplog_api.dart';
import '../../infrastructure/api/sensor_aggregated_api.dart';
import '../controllers/alarm_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/profile_controller.dart';
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
final sensorAggregatedApiProvider = Provider<SensorAggregatedApi>((ref) {
  return SensorAggregatedApi(ref);
});
final aiApiProvider = Provider<AIApi>((ref) {
  return AIApi(ref);
});
final profileApiProvider = Provider<ProfileApi>((ref) {
  return ProfileApi(ref);
});
final fcmApiProvider = Provider<FcmApi>((ref) {
  return FcmApi(ref);
});
final notificationApiProvider = Provider<NotificationApi>((ref) {
  return NotificationApi(ref);
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
final sensorAggregatedRepositoryProvider = Provider<SensorRepository>((ref) {
  final api = ref.read(sensorAggregatedApiProvider);
  return SensorImpl(api: api);
});
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final api = ref.read(aiApiProvider);
  return AIImpl(api: api);
});
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final api = ref.read(profileApiProvider);
  return ProfileImpl(api: api);
});
final fcmRepositoryProvider = Provider<FcmRepository>((ref) {
  final api = ref.read(fcmApiProvider);
  return FcmImpl(api: api);
});
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final api = ref.read(notificationApiProvider);
  return NotificationImpl(api: api);
});


// ! USECASE
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
final sensorAggregatedUsecaseProvider = Provider<SensorAggregatedUsecase>((ref) {
  final repo = ref.read(sensorAggregatedRepositoryProvider);
  return SensorAggregatedUsecase(repo);
});
final deviceUsecaseProvider = Provider<DeviceUsecase>((ref) {
  final repo = ref.read(deviceRepositoryProvider);
  return DeviceUsecase(repo);
});
final aiUsecaseProvider = Provider<AIUsecase>((ref) {
  final repo = ref.read(aiRepositoryProvider);
  return AIUsecase(repo);
});
final profileUsecaseProvider = Provider<ProfileUsecase>((ref) {
  final repo = ref.read(profileRepositoryProvider);
  return ProfileUsecase(repo);
});
final fcmUsecaseProvider = Provider<FcmUsecase>((ref) {
  final repo = ref.read(fcmRepositoryProvider);
  return FcmUsecase(repo);
});
final notificationUsecaseProvider = Provider<NotificationUsecase>((ref) {
  final repo = ref.read(notificationRepositoryProvider);
  return NotificationUsecase(repo);
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

final historyControllerProvider = Provider<HistoryController>((ref) {
  final sensorAggregatedUsecase = ref.read(sensorAggregatedUsecaseProvider);
  final pumplogUsecase = ref.read(pumplogUsecaseProvider);
  return HistoryController(
    sensorAggregatedUsecase: sensorAggregatedUsecase,
    pumplogUsecase: pumplogUsecase,
    ref: ref,
  );
});
final homeControllerProvider = Provider<HomeController>((ref) {
  final deviceUsecase = ref.read(deviceUsecaseProvider);
  final pumplogUsecase = ref.read(pumplogUsecaseProvider);
  final aiUsecase = ref.read(aiUsecaseProvider);
  return HomeController(
    deviceUsecase,
    ref,
    pumplogUsecase,
    aiUsecase,
  );
});
final profileControllerProvider = Provider<ProfileController>((ref) {
  final profileUsecase = ref.read(profileUsecaseProvider);
  return ProfileController(
    profileUsecase: profileUsecase, ref: ref,
  );
});
