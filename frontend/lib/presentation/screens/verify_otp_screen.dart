import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/radius_size.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';
import 'package:frontend/core/utils/hide_email_address.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/states/signup_state.dart';
import 'package:frontend/presentation/states/verify_otp.dart';
import 'package:frontend/presentation/widgets/global/app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.email,
    this.password,
    this.username,
    this.previousScreen,
  });

  final String email;
  final String? password;
  final String? username;
  final String? previousScreen;

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();
  final otpTimerController = OtpTimerButtonController();

  Timer? _timer;
  int _countdown = 30;
  bool canResend = false;

  late final String email = widget.email;
  late final String? password = widget.password;
  late final String? username = widget.username;
  late final String? previousScreen = widget.previousScreen;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
    _timer!.cancel();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _resendOtp() async {
    if (canResend) {
      setState(() {
        _countdown = 30;
        canResend = false;
      });

      final signupState = ref.read(signUpControllerProvider);
      ref
          .read(signUpControllerProvider.notifier)
          .signupEmail(
            email: signupState.email ?? '',
            password: signupState.password,
            username: signupState.username,
          );
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signUpControllerProvider);
    final mq = MediaQueryHelper.of(context);

    // cek dari reset-password atau signup
    final previousScreen = ref.read(resetPasswordControllerProvider).previousScreen ?? '/signup';

    // Listen verify OTP
    ref.listen<VerifyOtpState>(verifyOtpControllerProvider, (previous, next) {
      if (next is VerifyOtpSuccess) {
        // register
        if (ref.read(signUpControllerProvider).username != null &&
            ref.read(signUpControllerProvider).password != null) {
          
          ref
              .read(registerWithEmailControllerProvider.notifier)
              .registerWithEmail(
                username: ref.read(signUpControllerProvider).username!,
                email: ref.read(signUpControllerProvider).email ?? '',
                password: ref.read(signUpControllerProvider).password!,
              );
          context.go('/success-signup');
        } else {
          // reset password
          context.go('/create-new-password', extra: {'email': widget.email});
        }
      } else if (next is VerifyOtpFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage)));
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

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: AppSpacingSize.l),
                      child: AppBarWidget(
                        type: AppBarType.back,
                        title: "Verify Your OTP",
                        onBack: () {
                          if (previousScreen == 'reset-password') {
                            context.go('/reset-password');
                          } else {
                            context.go('/signup');
                          }
                        },
                      ),
                    ),
                    Text(
                      'Enter Your Verification Code',
                      style: TextStyle(
                        fontSize: AppFontSize.xxl,
                        fontWeight: AppFontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: AppSpacingSize.m),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'We sent a 6-digit verification code to ',
                            style: TextStyle(
                              fontSize: AppFontSize.m,
                              color: AppColors.black,
                            ),
                          ),
                          TextSpan(
                            text:
                                '${hideEmail(ref.read(signUpControllerProvider).email ?? ref.read(resetPasswordControllerProvider).email!)}. ',
                            style: TextStyle(
                              fontSize: AppFontSize.m,
                              color: AppColors.orange,
                              fontWeight: AppFontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'The OTP is valid for 10 minutes.',
                            style: TextStyle(
                              fontSize: AppFontSize.m,
                              color: AppColors.black,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacingSize.xl),
                    Pinput(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      length: 6,
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.length != 6) {
                          return 'Enter a valid 6-digit code';
                        }
                        return null;
                      },
                      onCompleted: (pin) {
                        final controllerVerifyOtp = ref.read(
                          verifyOtpControllerProvider.notifier,
                        );

                        controllerVerifyOtp.verifyOtp(
                          email: email,
                          otp: pin.trim(),
                        );
                      },
                      defaultPinTheme: PinTheme(
                        width: 50,
                        height: 56,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grayLight),
                          borderRadius: BorderRadius.circular(AppRadius.rm),
                          color: AppColors.white,
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 50,
                        height: 56,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.orange,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.rm),
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacingSize.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '00:${_countdown.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: AppFontSize.m,
                            color: AppColors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Didn't receive otp?  ",
                              style: TextStyle(
                                fontSize: AppFontSize.m,
                                color: AppColors.black,
                              ),
                            ),
                            canResend
                                ? InkWell(
                                  child: Text(
                                    'Resend',
                                    style: TextStyle(
                                      fontSize: AppFontSize.m,
                                      color: AppColors.orange,
                                      fontWeight: AppFontWeight.semiBold,
                                    ),
                                  ),
                                  onTap: () => _resendOtp(),
                                )
                                : Text(
                                  'Resend',
                                  style: TextStyle(
                                    fontSize: AppFontSize.m,
                                    color: AppColors.grayLight,
                                    fontWeight: AppFontWeight.semiBold,
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
          if (signupState is SignupLoading)
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
