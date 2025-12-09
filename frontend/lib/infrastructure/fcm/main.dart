import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static final _fcm = FirebaseMessaging.instance;

  static Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
