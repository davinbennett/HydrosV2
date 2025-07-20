import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';

final deviceIdProvider = StateNotifierProvider<DeviceIdNotifier, String?>((
  ref,
) {
  return DeviceIdNotifier()..loadDeviceId();
});

class DeviceIdNotifier extends StateNotifier<String?> {
  DeviceIdNotifier() : super(null);

  Future<void> loadDeviceId() async {
    final id = await SecureStorage.getDeviceId();
    state = id;
  }

  Future<void> setDeviceId(String id) async {
    await SecureStorage.saveDeviceId(id);
    state = id;
  }

  Future<void> clearDeviceId() async {
    await SecureStorage.deleteDeviceId();
    state = null;
  }
}
