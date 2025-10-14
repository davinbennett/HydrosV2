import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/core/utils/validator.dart';
import 'package:frontend/presentation/providers/injection.dart';
import 'package:frontend/presentation/widgets/global/button.dart';
import 'package:frontend/presentation/widgets/global/app_bar.dart';
import 'package:frontend/presentation/widgets/global/text_form_field.dart';
import 'package:go_router/go_router.dart';

class CreateNewPasswordScreen extends ConsumerStatefulWidget {
  const CreateNewPasswordScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState
    extends ConsumerState<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> handleCreate() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => isLoading = true);

    final controller = ref.read(newPasswordControllerProvider);

    final errorMessage = await controller.newPassword(
      email: widget.email,
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } else {
      context.go('/success-update-password');
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isLoading,
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
                        onPressed: handleCreate,
                      ),
                    ),
                  ],
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
