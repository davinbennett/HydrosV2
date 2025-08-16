import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/core/utils/validator.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/states/new_password_state.dart.dart';
import 'package:frontend/presentation/widgets/global/button.dart';
import 'package:frontend/presentation/widgets/global/app_bar.dart';
import 'package:frontend/presentation/widgets/global/text_form_field.dart';
import 'package:go_router/go_router.dart';

class CreateNewPasswordScreen extends ConsumerWidget {
  CreateNewPasswordScreen({super.key, required this.email});

  final String email;

  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Form
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQueryHelper.of(context);
    final newPasswordState = ref.watch(newPasswordControllerProvider);

    ref.listen<NewPasswordState>(newPasswordControllerProvider, (
      previous,
      next,
    ) {
      if (next is NewPasswordFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage)));
      } else if (next is NewPasswordSuccess) {
        context.go(
          '/success-update-password',
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

    void handleCreate(String email) async {
      final isValid = _formKey.currentState?.validate() ?? false;

      if (!isValid) return;

      final controller = ref.read(newPasswordControllerProvider.notifier);

      await controller.newPassword(
        email: email,
        password: passwordController.text.trim(),
      );
    }


    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: newPasswordState is NewPasswordLoading,
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
                      title: "Create New Password",
                      onBack: () => context.go('/login'),
                    ),

                    // BODY DI TENGAH
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: SizedBox(
                                  width: 275,
                                  child: Image.asset(
                                    'lib/assets/images/create_new_password.png',
                                  ),
                                ),
                              ),
                              Text(
                                'Enter New Password',
                                style: TextStyle(
                                  fontSize: AppFontSize.xl,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: AppSpacingSize.s),

                              Text(
                                'Your new password must be different from the previous used password',
                                style: TextStyle(
                                  fontSize: AppFontSize.m,
                                  color: AppColors.black,
                                ),
                              ),

                              SizedBox(height: AppSpacingSize.xl),

                              // Password
                              TextFormFieldWidget(
                                label: 'Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                controller: passwordController,
                                validator: AppValidator.password,
                              ),

                              SizedBox(height: AppSpacingSize.s),

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
                        ),
                      ),
                    ),

                    // BUTTON PALING BAWAH
                    Padding(
                      padding: EdgeInsets.only(bottom: AppSpacingSize.l),
                      child: ButtonWidget(
                        text: "Create",
                        onPressed: () => handleCreate(email),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (newPasswordState is NewPasswordLoading)
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
