import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';
import '../../infrastructure/fcm/main.dart';
import '../../infrastructure/local_notification/localnotif_main.dart';
import '../states/notification_state.dart';
import 'injection.dart';
import 'notif_setting.dart';

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
      (ref) => NotificationNotifier(ref),
    );

class NotificationNotifier extends StateNotifier<NotificationState> {
  final Ref ref;
  bool _isRegistering = false;

  NotificationNotifier(this.ref) : super(const NotificationState()) {
    _initFCMListener(); // realtime listener
  }

  int get unreadCount {
    return state.listNotification.where((n) => n["is_read"] == false).length;
  }

  // REALTIME FCM → STATE (TANPA HIT API)
  void _initFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // ✅ CEK DULU SETTING NOTIF
      final isNotifOn = ref.read(notificationSettingProvider);

      if (!isNotifOn) {
        logger.w("🔕 Notif blocked by user setting");
        return; // ⛔ STOP TOTAL
      }

      // 1. TAMPILKAN LOCAL NOTIFIKASI
      final notif = message.notification;
      if (notif != null) {
        LocalNotificationService.showInstant(
          title: notif.title ?? 'Hydros',
          body: notif.body ?? '',
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
      }

      // 2. ✅ MASUKKAN KE STATE
      insertFromFCM(message);
    });
  }

  // ✅ LOAD MANUAL DARI BACKEND (UNTUK PERTAMA KALI / PULL TO REFRESH)
  Future<void> loadNotifications() async {
    try {
      state = state.copyWith(isLoading: true);

      final api = ref.read(notificationApiProvider);
      final result = await api.getMyNotificationsApi();

      final rawList = List<Map<String, dynamic>>.from(result);

      final parsed =
          rawList.map((raw) {
            final id = raw["id"] ?? raw["ID"] ?? 0;

            return {
              "id": id is int ? id : int.tryParse(id.toString()) ?? 0,
              "title": raw["title"] ?? raw["Title"] ?? "",
              "body": raw["body"] ?? raw["Body"] ?? "",
              "type": raw["type"] ?? raw["Type"] ?? "general",
              "is_read": raw["is_read"] ?? raw["IsRead"] ?? false,
              "created_at": raw["created_at"] ?? raw["CreatedAt"] ?? "",
            };
          }).toList();

      state = state.copyWith(listNotification: parsed, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// ✅ MARK AS READ
  Future<void> readNotification(int id) async {
    final api = ref.read(notificationApiProvider);
    await api.readNotificationApi(id);

    final updated =
        state.listNotification.map((n) {
          if (n["id"] == id) {
            return {...n, "is_read": true};
          }
          return n;
        }).toList();

    state = state.copyWith(listNotification: updated);
  }

  /// ✅ DELETE
  Future<void> deleteNotification(int id) async {
    final api = ref.read(notificationApiProvider);
    await api.deleteNotificationApi(id);
  }

  void removeFromLocal(int id) {
    final updated = state.listNotification.where((n) => n["id"] != id).toList();

    state = state.copyWith(listNotification: updated);
  }

  /// ✅ CLEAR ALL (LOGOUT / UNPAIR)
  void clearAll() {
    state = const NotificationState();
    _isRegistering = false;
  }

  /// ✅ REGISTER FCM TOKEN (LOGIN & FIRST OPEN)
  Future<void> registerFcmToken(String? deviceId) async {
    if (_isRegistering) return;
    _isRegistering = true;

    logger.i("✅ REGISTER FCM TOKEN");

    try {
      final token = await FCMService.getToken();
      logger.i("Token FCM: $token");
      if (token == null) {
        _isRegistering = false;
        return;
      }

      final fcmApi = ref.read(fcmApiProvider);
      await fcmApi.sendTokenToBackendApi(token, deviceId);
    } finally {
      _isRegistering = false;
    }
  }

  /// ✅ INJECT NOTIFIKASI DARI FCM KE STATE (REALTIME POPUP)
  void insertFromFCM(RemoteMessage message) {
    final notif = message.notification;
    final data = message.data;

    if (notif == null) return;

    final notifId = int.tryParse(data["notification_id"]?.toString() ?? "");

    if (notifId == null || notifId == 0) {
      logger.w("❌ Invalid notification_id from FCM");
      return;
    }

    // ✅ CEK DUPLIKASI
    final exists = state.listNotification.any((n) => n["id"] == notifId);
    if (exists) {
      logger.i("ℹ️ Notification $notifId already exists, skipped");
      return;
    }

    final newNotif = {
      "id": notifId,
      "title": notif.title ?? "",
      "body": notif.body ?? "",
      "type": data["type"] ?? "general",
      "is_read": false,
      "created_at": data["created_at"] ?? DateTime.now().toIso8601String(),
    };

    final updated = [newNotif, ...state.listNotification];
    state = state.copyWith(listNotification: updated);
  }
}
