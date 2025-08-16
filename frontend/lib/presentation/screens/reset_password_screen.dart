import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/core/utils/validator.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/states/reset_password_state.dart';
import 'package:frontend/presentation/widgets/global/button.dart';
import 'package:frontend/presentation/widgets/global/app_bar.dart';
import 'package:frontend/presentation/widgets/global/text_form_field.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends ConsumerWidget {
  ResetPasswordScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  // Form
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQueryHelper.of(context);
    final resetPasswordState = ref.watch(resetPasswordControllerProvider);

    ref.listen<ResetPasswordState>(resetPasswordControllerProvider, (
      previous,
      next,
    ) {
      if (next is ResetPasswordFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage)));
      } else if (next is ResetPasswordSuccess) {
        context.go(
          '/verify-otp',
          extra: {
            'previous-screen': '/reset-password',
            'email': emailController.text.trim(),
          },
        );
      }
    });

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            mq.isPortrait ? AppColors.secondary : AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );

    void handleSend() async {
      final isValid = _formKey.currentState?.validate() ?? false;

      if (!isValid) return;

      final controller = ref.read(resetPasswordControllerProvider.notifier);

      await controller.resetPassword(
        email: emailController.text.trim()
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: resetPasswordState is ResetPasswordLoading,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacingSize.l,
                  right: AppSpacingSize.l,
                  top: mq.notchHeight * 1.5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // APPBAR PALING ATAS
                    AppBarWidget(
                      type: AppBarType.back,
                      title: "Reset Your Password",
                      onBack: () => context.go('/login'),
                    ),
              
                    // BODY DI TENGAH
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 275,
                              child: Image.asset(
                                'lib/assets/images/reset_your_password.png',
                              ),
                            ),
                            SizedBox(height: AppSpacingSize.l),
                            Text(
                              'Enter your email to receive a verification code',
                              style: TextStyle(
                                fontSize: AppFontSize.xl,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: AppSpacingSize.l),
                            Form(
                              key: _formKey,
                              child: TextFormFieldWidget(
                                label: 'Email',
                                icon: Icons.email_outlined,
                                controller: emailController,
                                validator: AppValidator.email,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              
                    // BUTTON PALING BAWAH
                    Padding(
                      padding: EdgeInsets.only(bottom: AppSpacingSize.l),
                      child: ButtonWidget(
                        text: "Send",
                        onPressed: () => handleSend(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (resetPasswordState is ResetPasswordLoading)
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
