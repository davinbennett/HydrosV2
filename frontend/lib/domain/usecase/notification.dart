import '../repositories/notification.dart';

class NotificationUsecase {
  final NotificationRepository repository;

  NotificationUsecase(this.repository);

  Future<String> getMyNotificationsUsecase() async {
    return await repository.getMyNotificationsImpl();
  }

  Future<String> readNotificationUsecase(int? id) async {
    return await repository.readNotificationImpl(id);
  }

  Future<String> deleteNotificationUsecase(int? id) async {
    return await repository.deleteNotificationImpl(id);
  }
}
