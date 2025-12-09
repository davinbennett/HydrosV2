
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/utils/logger.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logger.i("✅ BACKGROUND FCM MASUK");
  logger.i("TITLE: ${message.notification?.title}");
  logger.i("BODY: ${message.notification?.body}");
}
