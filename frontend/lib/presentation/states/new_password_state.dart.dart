sealed class NewPasswordState {
  final String? password;
  final String? email;

  const NewPasswordState({
    this.email,
    this.password
  });
}

class NewPasswordInitial extends NewPasswordState {
  const NewPasswordInitial({super.email, super.password});
}

class NewPasswordLoading extends NewPasswordState {
  const NewPasswordLoading({super.email, super.password});
}

class NewPasswordSuccess extends NewPasswordState {
  const NewPasswordSuccess({super.email, super.password});
}

class NewPasswordFailure extends NewPasswordState {
  final String errorMessage;

  const NewPasswordFailure(
    this.errorMessage, {
      super.email, super.password,
    }
  );
}
