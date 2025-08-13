sealed class SignupState {
  final String? email;
  final String? password;
  final String? username;

  const SignupState({this.email, this.password, this.username});
}

class SignupInitial extends SignupState {
  const SignupInitial({super.email, super.password, super.username});
}

class SignupLoading extends SignupState {
  const SignupLoading({super.email, super.password, super.username});
}

class SignupSuccess extends SignupState {
  const SignupSuccess({super.email, super.password, super.username});
}

class SignupFailure extends SignupState {
  final String errorMessage;

  const SignupFailure(
    this.errorMessage, {
    super.email,
    super.password,
    super.username,
  });
}




sealed class RegisterWithEmailState {}

class RegisterWithEmailInitial extends RegisterWithEmailState {}

class RegisterWithEmailLoading extends RegisterWithEmailState {}

class RegisterWithEmailSuccess extends RegisterWithEmailState {}

class RegisterWithEmailFailure extends RegisterWithEmailState {
  final String errorMessage;
  RegisterWithEmailFailure(this.errorMessage);
}
