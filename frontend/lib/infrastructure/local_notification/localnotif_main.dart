import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final _notification = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const initSettings = InitializationSettings(android: android, iOS: ios);

    await _notification.initialize(initSettings);
  }

  /// NOTIFIKASI LANGSUNG
  static Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'hydros_channel',
      'Hydros Notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notifDetails = NotificationDetails(android: androidDetails);

    await _notification.show(id, title, body, notifDetails);
  }

  /// NOTIFIKASI TERJADWAL (SUDAH API BARU v17+)
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await _notification.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hydros_channel',
          'Hydros Notification',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// HAPUS NOTIFIKASI (UNTUK UNPAIR / DELETE ALARM)
  static Future<void> cancel(int id) async {
    await _notification.cancel(id);
  }

  /// HAPUS SEMUA NOTIFIKASI
  static Future<void> cancelAll() async {
    await _notification.cancelAll();
  }
}
