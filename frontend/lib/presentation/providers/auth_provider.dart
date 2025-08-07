import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/auth/login_with_email.dart';
import 'package:frontend/domain/usecase/auth/login_with_google.dart';
import 'package:frontend/presentation/controllers/login_controller.dart';
import 'package:frontend/presentation/controllers/splash_controller.dart';
import 'package:frontend/presentation/providers/injection.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

final statusLoginProvider = StateNotifierProvider<SplashController, AuthStatus>((ref) {
  return SplashController()..checkLogin();
});

final loginControllerProvider =
    StateNotifierProvider<LoginController, AuthStatus>((ref) {
      final authRepository = ref.read(authRepositoryProvider);

      return LoginController(
        loginEmailUsecase: LoginWithEmailUseCase(authRepository),
        loginGoogleUsecase: LoginWithGoogleUseCase(authRepository),
      );
    });
