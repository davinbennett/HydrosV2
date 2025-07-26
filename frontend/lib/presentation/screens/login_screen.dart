import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';
import 'package:frontend/core/utils/validator.dart';
import 'package:frontend/presentation/controllers/login_controller.dart';
import 'package:frontend/presentation/widgets/global/button.dart';
import 'package:frontend/presentation/widgets/global/text_form_field.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    final statusBarHeight = mediaQueryData.padding.top;
    final bottomPadding = mediaQueryData.padding.bottom;
    final safeScreenHeight = screenHeight - statusBarHeight - bottomPadding;

    final controller = ref.watch(loginControllerProvider);
    final controllerNotifier = ref.read(loginControllerProvider.notifier);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.secondary,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: safeScreenHeight),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    // ! TOP
                    Column(
                      children: [
                        // Judul dan subtitle
                        FittedBox(
                          child: Text(
                            'Welcome Back, Hydromers!',
                            style: TextStyle(
                              fontSize: AppFontSize.xxl,
                              fontWeight: AppFontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        FittedBox(
                          child: Text(
                            'Sign in to manage your smart irrigation system',
                            style: TextStyle(
                              fontSize: AppFontSize.s,
                              fontStyle: FontStyle.italic,
                              fontWeight: AppFontWeight.light,
                            ),
                          ),
                        ),

                        // Gambar
                        SizedBox(
                          height: 150.h,
                          child: Image.asset(
                            'lib/assets/images/login.png',
                          ), // Pastikan ada file ini
                        ),
                      ],
                    ),

                    // ! MID
                    Column(
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
                              minimumSize: Size(
                                0,
                                0,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: AppColors.grayLight,
                                fontSize: AppFontSize.s,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ! BOTTOM
                    Column(
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
                                style: TextStyle(color: AppColors.grayLight),
                              ),
                            ),
                            Expanded(child: Divider(color: AppColors.grayLight)),
                          ],
                        ),
                        
                        // Google Button
                        ButtonWidget(
                          text: "Google",
                          onPressed: () {},
                          svgAsset: 'lib/assets/icons/google.svg',
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
                                fontSize: AppFontSize.s,
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
                                  fontSize: AppFontSize.s,
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
      ),
    );
  }
}
