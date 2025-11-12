import 'package:frontend/domain/repositories/device.dart';

class ControlPumpUsecase {
  final DeviceRepository repository;

  ControlPumpUsecase(this.repository);

  Future<bool> controlPumpSwitchUsecase(String deviceId, bool switchValue) async {
    return await repository.controlPumpSwitchImpl(deviceId, switchValue);
  }
}