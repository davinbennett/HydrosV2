import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/states/device_state.dart';

final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>((
  ref,
) {
  return DeviceNotifier();
});


class DeviceNotifier extends StateNotifier<DeviceState> {
  DeviceNotifier() : super(const DeviceState()) {
    _restoreFromStorage();
  }

  Future<void> _restoreFromStorage() async {
    final deviceId = await SecureStorage.getDeviceId();
    final hasPlant = await SecureStorage.getHasPlant();

    if (deviceId != null && deviceId.isNotEmpty) {
      if (hasPlant == true) {
        setPairedWithPlant(deviceId);
      } else {
        setPairedNoPlant(deviceId);
      }
    }
  }

  void setUnpaired(String deviceId) {
    final updated = Map<String, DevicePairState>.from(state.devices)
      ..[deviceId] = Unpaired();
    state = state.copyWith(devices: updated);
  }

  void setPairedNoPlant(String deviceId) {
    final updated = Map<String, DevicePairState>.from(state.devices)
      ..[deviceId] = PairedNoPlant(deviceId);
    state = state.copyWith(devices: updated);
  }

  void setPairedWithPlant(String deviceId) {
    final updated = Map<String, DevicePairState>.from(state.devices)
      ..[deviceId] = PairedWithPlant(deviceId);
    state = state.copyWith(devices: updated);
  }

  void removeDevice(String deviceId) {
    final updated = Map<String, DevicePairState>.from(state.devices)
      ..remove(deviceId);
    state = state.copyWith(devices: updated);
  }

  void resetDevices() {
    state = const DeviceState();
  }
}
