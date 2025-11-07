// presentation/states/device_state.dart
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
/// State untuk tiap device
sealed class DevicePairState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DevicePairFailure extends DevicePairState {
  final String message;
  DevicePairFailure(this.message);
}

class Unpaired extends DevicePairState {
  Unpaired();
}

class PairedNoPlant extends DevicePairState {
  final String deviceId;
  PairedNoPlant(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class PairedWithPlant extends DevicePairState {
  final String deviceId;
  PairedWithPlant(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

/// ------------------------------
/// State global menyimpan semua device
/// ------------------------------
class DeviceState extends Equatable {
  final Map<String, DevicePairState> devices;

  const DeviceState({this.devices = const {}});

  DeviceState copyWith({Map<String, DevicePairState>? devices}) {
    return DeviceState(devices: devices ?? this.devices);
  }

  // helper: cek status state device saat ini
  DevicePairState? get activePairState => devices.values.firstWhereOrNull(
    (state) => state is PairedNoPlant || state is PairedWithPlant,
  );


  /// Cek apakah ada device yang sudah paired (tanpa/ dengan plant)
  bool get hasPairedDevice {
    return devices.values.any(
      (state) => state is PairedNoPlant || state is PairedWithPlant,
    );
  }

  /// Ambil state dari device tertentu
  DevicePairState? getDeviceState(String deviceId) => devices[deviceId];

  /// Ambil deviceId yang sudah paired (jika ada)
  String? get pairedDeviceId {
    try {
      final entry = devices.entries.firstWhere(
        (e) => e.value is PairedNoPlant || e.value is PairedWithPlant,
      );
      return entry.key;
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [devices];
}
