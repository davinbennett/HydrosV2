import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/states/device_state.dart';

/// Provider utama untuk menyimpan dan mengatur daftar device
final deviceProvider = StateProvider<DeviceState>((ref) {
  return const DeviceState();
});

/// Extension agar lebih enak dipakai
extension DeviceProviderX on WidgetRef {
  void setUnpaired(int deviceId) {
    final current = read(deviceProvider);
    final updated = Map<int, DevicePairState>.from(current.devices)
      ..[deviceId] = const Unpaired();
    read(deviceProvider.notifier).state = current.copyWith(devices: updated);
  }

  void setPairedNoPlant(int deviceId) {
    final current = read(deviceProvider);
    final updated = Map<int, DevicePairState>.from(current.devices)
      ..[deviceId] = PairedNoPlant(deviceId);
    read(deviceProvider.notifier).state = current.copyWith(devices: updated);
  }

  void setPairedWithPlant(int deviceId) {
    final current = read(deviceProvider);
    final updated = Map<int, DevicePairState>.from(current.devices)
      ..[deviceId] = PairedWithPlant(deviceId);
    read(deviceProvider.notifier).state = current.copyWith(devices: updated);
  }

  void removeDevice(int deviceId) {
    final current = read(deviceProvider);
    final updated = Map<int, DevicePairState>.from(current.devices)
      ..remove(deviceId);
    read(deviceProvider.notifier).state = current.copyWith(devices: updated);
  }

  void resetDevices() {
    read(deviceProvider.notifier).state = const DeviceState();
  }
}
