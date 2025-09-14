sealed class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final String message;
  HomeSuccess(this.message);
}

class HomeFailure extends HomeState {
  final String errorMessage;
  HomeFailure(this.errorMessage);
}
