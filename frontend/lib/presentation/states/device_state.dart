// presentation/states/device_state.dart
import 'package:equatable/equatable.dart';

/// State untuk tiap device
sealed class DevicePairState extends Equatable {
  const DevicePairState();

  @override
  List<Object?> get props => [];
}

class Unpaired extends DevicePairState {
  const Unpaired();
}

class PairedNoPlant extends DevicePairState {
  final int deviceId;
  const PairedNoPlant(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class PairedWithPlant extends DevicePairState {
  final int deviceId;
  const PairedWithPlant(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

/// State global menyimpan semua device
class DeviceState extends Equatable {
  final Map<int, DevicePairState> devices;

  const DeviceState({this.devices = const {}});

  DeviceState copyWith({Map<int, DevicePairState>? devices}) {
    return DeviceState(devices: devices ?? this.devices);
  }

  @override
  List<Object?> get props => [devices];
}
