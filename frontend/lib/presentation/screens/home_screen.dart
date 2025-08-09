import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/core/utils/validator.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/widgets/global/button.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});
  
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
      ),
    );

    _logSecureStorage();

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacingSize.l,
          right: AppSpacingSize.l,
          top: mq.notchHeight * 1.5,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: mq.safeHeight),
          child: Column(
            children: [
              // ! TOP
              Text(
                'HOME SCREEN',
                style: TextStyle(
                  fontSize: AppFontSize.xl,
                  fontWeight: AppFontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                'HOME SCREEN',
                style: TextStyle(
                  fontSize: AppFontSize.xl,
                  fontWeight: AppFontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
