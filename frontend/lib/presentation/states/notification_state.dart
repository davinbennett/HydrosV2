import 'package:equatable/equatable.dart';

class NotificationState extends Equatable {
  final List<Map<String, dynamic>> listNotification;
  final bool isLoading;

  const NotificationState({
    this.listNotification = const [],
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<Map<String, dynamic>>? listNotification,
    bool? isLoading,
  }) {
    return NotificationState(
      listNotification: listNotification ?? this.listNotification,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [listNotification, isLoading];
}
