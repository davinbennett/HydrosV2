
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';


final notificationSettingProvider =
    StateNotifierProvider<NotificationSettingNotifier, bool>(
      (ref) => NotificationSettingNotifier(),
    );

class NotificationSettingNotifier extends StateNotifier<bool> {
  NotificationSettingNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final val = await SecureStorage.getIsNotifOn();
    state = val;
  }

  Future<void> toggle(bool value) async {
    state = value;
    await SecureStorage.saveIsNotifOn(value);
  }
}

