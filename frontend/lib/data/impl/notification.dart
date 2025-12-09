import '../../domain/repositories/notification.dart';
import '../../infrastructure/api/notification_api.dart';

class NotificationImpl implements NotificationRepository {
  final NotificationApi api;
  NotificationImpl({required this.api});

  @override
  Future<dynamic> getMyNotificationsImpl() async {
    return api.getMyNotificationsApi();
  }

  @override
  Future<String> readNotificationImpl(int? id) {
    return api.readNotificationApi(id);
  }

  @override
  Future<String> deleteNotificationImpl(int? id) {
    return api.deleteNotificationApi(id);
  }
}
