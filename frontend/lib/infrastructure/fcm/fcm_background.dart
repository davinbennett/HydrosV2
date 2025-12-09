
import 'package:firebase_messaging/firebase_messaging.dart';

import '../local/secure_storage.dart';
import '../local_notification/localnotif_main.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final isNotifOn = await SecureStorage.getIsNotifOn();

  if (!isNotifOn) {
    return; // ⛔ BENAR-BENAR DIBLOCK
  }

  final notif = message.notification;
  if (notif != null) {
    await LocalNotificationService.showInstant(
      title: notif.title ?? 'Hydros',
      body: notif.body ?? '',
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }
}
