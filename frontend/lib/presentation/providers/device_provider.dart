import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/states/device_state.dart';

final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>((
  ref,
) {
  return DeviceNotifier();
});


class DeviceNotifier extends StateNotifier<DeviceState> {
  DeviceNotifier() : super(const DeviceState());

  void setUnpaired(int deviceId) {
    final updated = Map<int, DevicePairState>.from(state.devices)
      ..[deviceId] = Unpaired();
    state = state.copyWith(devices: updated);
  }

  void setPairedNoPlant(int deviceId) {
    final updated = Map<int, DevicePairState>.from(state.devices)
      ..[deviceId] = PairedNoPlant(deviceId);
    state = state.copyWith(devices: updated);
  }

  void setPairedWithPlant(int deviceId) {
    final updated = Map<int, DevicePairState>.from(state.devices)
      ..[deviceId] = PairedWithPlant(deviceId);
    state = state.copyWith(devices: updated);
  }

  void removeDevice(int deviceId) {
    final updated = Map<int, DevicePairState>.from(state.devices)
      ..remove(deviceId);
    state = state.copyWith(devices: updated);
  }

  void resetDevices() {
    state = const DeviceState();
  }
}
