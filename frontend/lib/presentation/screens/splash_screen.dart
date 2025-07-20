import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

// Ganti StatefulWidget jadi ConsumerStatefulWidget
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      final authStatus = ref.read(authProvider);

      if (authStatus == AuthStatus.authenticated) {
        context.go('/app/home');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
