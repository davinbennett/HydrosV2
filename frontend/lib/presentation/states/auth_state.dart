import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entities/auth.dart';

sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthUnauthenticated extends AuthState {
  AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  final AuthEntity user;
  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthSignupSuccess extends AuthState {
  AuthSignupSuccess();
}

class AuthOtpVerified extends AuthState {
  AuthOtpVerified();
}

class AuthResetRequested extends AuthState {
  AuthResetRequested();
}

class AuthPasswordReset extends AuthState {
  AuthPasswordReset();
}

class AuthToForgotPassword extends AuthState {
  AuthToForgotPassword();
}

class AuthSessionExpired extends AuthState {
  AuthSessionExpired();
}
