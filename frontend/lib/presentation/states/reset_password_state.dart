sealed class ResetPasswordState {
  final String? previousScreen;
  final String? email;

  const ResetPasswordState({
    this.email,
    this.previousScreen
  });
}

class ResetPasswordInitial extends ResetPasswordState {
  const ResetPasswordInitial({super.email, super.previousScreen});
}

class ResetPasswordLoading extends ResetPasswordState {
  const ResetPasswordLoading({super.email, super.previousScreen});
}

class ResetPasswordSuccess extends ResetPasswordState {
  const ResetPasswordSuccess({super.email, super.previousScreen});
}

class ResetPasswordFailure extends ResetPasswordState {
  final String errorMessage;

  const ResetPasswordFailure(
    this.errorMessage, {
      super.email, super.previousScreen,
    }
  );
}
