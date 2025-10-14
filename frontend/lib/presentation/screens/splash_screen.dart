import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/states/auth_state.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.secondary,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      final authState = ref.read(authProvider);

      authState.when(
        data: (state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else {
            context.go('/login');
          }
        },
        loading: () => null,
        error: (_, _) => context.go('/login'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // ! delete secure storage sementara
    // Future.microtask(() => SecureStorage .clearAll());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Image.asset(
            'lib/assets/images/splash.png',
            width: 225.w,
            height: 225.h,
          ),
        ),
      ),
    );
  }
}
