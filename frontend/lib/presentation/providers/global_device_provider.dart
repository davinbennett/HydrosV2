import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/states/global_device_state.dart';

class GlobalDeviceController extends StateNotifier<GlobalDeviceState> {
  GlobalDeviceController() : super(PairedWithPlant(1));

  void setUnPaired() {
    state = UnPaired();
  }

  void setPairedNoPlant(int deviceId) {
    state = PairedNoPlant(deviceId);
  }

  void setPairedWithPlant(int deviceId) {
    state = PairedWithPlant(deviceId);
  }
}

final globalDeviceProvider =
    StateNotifierProvider<GlobalDeviceController, GlobalDeviceState>((ref) {
      return GlobalDeviceController();
    });
