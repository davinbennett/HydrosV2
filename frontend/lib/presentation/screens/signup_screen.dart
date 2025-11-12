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
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/providers/injection.dart';
import 'package:frontend/presentation/states/auth_state.dart';
import 'package:frontend/presentation/widgets/global/button.dart';
import 'package:frontend/presentation/widgets/global/text_form_field.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> handleSignUp() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => isLoading = true);

    final controller = ref.read(signupControllerProvider);

    final result = await controller.signupEmail(
      email: emailController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result is AuthSignupSuccess) {
      ref.read(authProvider.notifier).setAuthenticated(AsyncValue.data(result));

      context.go(
        '/verify-otp',
        extra: {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'username': usernameController.text.trim(),
          'previousScreen': '/signup',
        },
      );
    } else if (result is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> handleGoogleLogin() async {
    setState(() => isLoading = true);

    final controller = ref.read(loginControllerProvider);

    final result = await controller.loginWithGoogle();
    ref.read(authProvider.notifier).setAuthenticated(AsyncValue.data(result));

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result is AuthAuthenticated) {
      context.go('/home');
    } else if (result is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryHelper.of(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            mq.isPortrait ? AppColors.secondary : AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isLoading,
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
                              'Join the Hydros Family!',
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
                              'Create your account to start smarter gardening',
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
                          // Username
                          TextFormFieldWidget(
                            label: 'Username',
                            icon: Icons.people_alt_outlined,
                            controller: usernameController,
                            validator: AppValidator.usernameRequired,
                          ),

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

                          // Confirm Password
                          TextFormFieldWidget(
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            controller: confirmPasswordController,
                            validator:
                                (value) => AppValidator.confirmPassword(
                                  passwordController.text,
                                  value,
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
                            text: "Sign Up",
                            onPressed: () => handleSignUp(),
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
                                  'Or Sign Up With',
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
                            onPressed: () => handleGoogleLogin(),
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
                                "Have an account?  ",
                                style: TextStyle(
                                  color: AppColors.gray,
                                  fontSize: AppFontSize.m,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.go('/login');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Sign In',
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
          if (isLoading)
            Container(
              color: const Color.fromARGB(
                55,
                0,
                0,
                0,
              ), // semi-transparent background
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
