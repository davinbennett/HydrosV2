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
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/states/login_state.dart';
import 'package:frontend/presentation/widgets/global/button.dart';
import 'package:frontend/presentation/widgets/global/text_form_field.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  // Form
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQueryHelper.of(context);
    final loginState = ref.watch(loginControllerProvider);

    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      logger.i('Login State: $next');

      if (next is LoginFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage)));
      } else if (next is LoginSuccess) {
        context.go('/home');
      }
    });

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            mq.isPortrait ? AppColors.secondary : AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent
      ),
    );

    // CONTROLLER
    void handleLogin(BuildContext context) async {
      final isValid = _formKey.currentState?.validate() ?? false;

      if (!isValid) return;

      final controller = ref.read(loginControllerProvider.notifier);

      await controller.loginEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    }

    void handleGoogleLogin(BuildContext context) async {
      final controller = ref.read(loginControllerProvider.notifier);
      await controller.loginWithGoogle();
    }

    return Scaffold(
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: loginState is LoginLoading,
            child: Container(
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
                child: Form(
                  key: _formKey,
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
                            child: Image.asset('lib/assets/images/login.png'),
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
                            controller: emailController,
                            validator: AppValidator.email,
                          ),
                            
                          // Password
                          TextFormFieldWidget(
                            label: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            controller: passwordController,
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
                        spacing: AppSpacingSize.l,
                        children: [
                          // Sign In button
                          ButtonWidget(
                            text: "Sign In",
                            onPressed: () => handleLogin(context),
                          ),
                            
                          // Divider with text
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: AppColors.grayLight),
                              ),
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
                              Expanded(
                                child: Divider(color: AppColors.grayLight),
                              ),
                            ],
                          ),
                            
                          // Google Button
                          ButtonWidget(
                            text: "Google",
                            onPressed: () => handleGoogleLogin(context),
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
                                  context.go('/signup');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
          if (loginState is LoginLoading)
            Container(
              color: const Color.fromARGB(55, 0, 0, 0), // semi-transparent background
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

        ],
      ),
    );
  }
}
