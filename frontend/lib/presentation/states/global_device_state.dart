sealed class GlobalDeviceState {
  GlobalDeviceState();
}

class UnPaired extends GlobalDeviceState {
  UnPaired();
}

class PairedNoPlant extends GlobalDeviceState {
  final int deviceId;
  PairedNoPlant(this.deviceId);
}

class PairedWithPlant extends GlobalDeviceState {
  final int deviceId;
  PairedWithPlant(this.deviceId);
}
