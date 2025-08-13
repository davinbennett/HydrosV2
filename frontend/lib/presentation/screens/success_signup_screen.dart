import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/widgets/global/button.dart';
import 'package:go_router/go_router.dart';

class SuccessSignUpScreen extends ConsumerWidget {
  SuccessSignUpScreen({super.key});

  Future<void> _logSecureStorage() async {
    final token = await SecureStorage.getAccessToken();
    final userId = await SecureStorage.getUserId();
    final deviceId = await SecureStorage.getDeviceId();

    logger.i('🔐 Access Token: $token');
    logger.i('👤 User ID: $userId');
    logger.i('📱 Device ID: $deviceId');
  }

  // Form
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQueryHelper.of(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            mq.isPortrait ? AppColors.secondary : AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );

    _logSecureStorage();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: AppSpacingSize.l,
                  right: AppSpacingSize.l,
                  top: mq.notchHeight * 1.5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 275,
                      child: Image.asset(
                        'lib/assets/images/success_signup.png',
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        'Registration Successful',
                        style: TextStyle(
                          fontSize: AppFontSize.xxl,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacingSize.s),
                    Text(
                      'Congratulations! Your account has been successfully registered',
                      style: TextStyle(
                        fontSize: AppFontSize.m,
                        fontWeight: FontWeight.normal,
                        color: AppColors.gray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacingSize.l),
              child: ButtonWidget(
                text: "Continue",
                onPressed: () {
                  context.go('/home');
                },
              ),
            ),
          ],
        ),
      ),
    );

  }
}
