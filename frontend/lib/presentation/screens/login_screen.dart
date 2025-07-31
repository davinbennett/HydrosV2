import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/core/utils/validator.dart';
import 'package:frontend/presentation/controllers/login_controller.dart';
import 'package:frontend/presentation/widgets/global/button.dart';
import 'package:frontend/presentation/widgets/global/text_form_field.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQueryHelper.of(context);

    final controller = ref.watch(loginControllerProvider);
    final controllerNotifier = ref.read(loginControllerProvider.notifier);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: mq.isPortrait ? AppColors.secondary : AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppSpacingSize.l,
            right: AppSpacingSize.l,
            top: mq.notchHeight * 1.5,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: mq.safeHeight),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  
                  // ! TOP
                  Column(
                    children: [

                      // Judul dan subtitle
                      FittedBox(
                        child: Text(
                          'Welcome Back, Hydromers!',
                          style: TextStyle(
                            fontSize: AppFontSize.xl,
                            fontWeight: AppFontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacingSize.xs),

                      FittedBox(
                        child: Text(
                          'Sign in to manage your smart irrigation system',
                          style: TextStyle(
                            fontSize: AppFontSize.m,
                            fontStyle: FontStyle.italic,
                            fontWeight: AppFontWeight.light,
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacingSize.xl),

                      // Gambar
                      SizedBox(
                        width: 200,
                        child: Image.asset(
                          'lib/assets/images/login.png',
                        ),
                      ),

                      SizedBox(height: AppSpacingSize.xl),
                    ],
                  ),

                  // ! MID
                  Column(
                    spacing: AppSpacingSize.s,
                    children: [
                      // Email
                      TextFormFieldWidget(
                        label: 'Email',
                        icon: Icons.email_outlined,
                        controller: controller.emailController,
                        validator: AppValidator.email,
                      ),

                      // Password
                      TextFormFieldWidget(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: controller.passwordController,
                        validator: AppValidator.password,
                      ),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: AppColors.grayLight,
                              fontSize: AppFontSize.m,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacingSize.xxl), 

                  // ! BOTTOM
                  Column(
                    spacing: AppSpacingSize.s,
                    children: [
                      // Sign In button
                      ButtonWidget(
                        text: "Sign In",
                        onPressed: () {
                          final isValid =
                              controller.formKey.currentState?.validate() ??
                              false;
                          if (isValid) {
                            controllerNotifier.login();
                          }
                        },
                      ),

                      // Divider with text
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.grayLight)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Or Sign In With',
                              style: TextStyle(
                                color: AppColors.grayLight,
                                fontSize: AppFontSize.s,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.grayLight)),
                        ],
                      ),

                      // Google Button
                      ButtonWidget(
                        text: "Google",
                        onPressed: () {},
                        svgAsset: SvgPicture.asset(
                          'lib/assets/icons/google.svg',
                          width: AppElementSize.m,
                        ),
                        isOutlined: true,
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.gray,
                        borderColor: AppColors.grayLight,
                      ),

                      // Sign up text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?  ",
                            style: TextStyle(
                              color: AppColors.gray,
                              fontSize: AppFontSize.m,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to signup
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.gray,
                                fontWeight: AppFontWeight.bold,
                                fontSize: AppFontSize.m,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
