abstract class NotificationRepository {
  Future<dynamic> getMyNotificationsImpl();
  Future<String> readNotificationImpl(int? id);
  Future<String> deleteNotificationImpl(int? id);
}
