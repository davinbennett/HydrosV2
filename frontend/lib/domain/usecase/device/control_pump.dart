import 'package:frontend/domain/repositories/device.dart';

class ControlPumpUsecase {
  final DeviceRepository repository;

  ControlPumpUsecase(this.repository);

  Future<bool> controlPumpSwitchUsecase(String deviceId, bool switchValue) async {
    return await repository.controlPumpSwitchImpl(deviceId, switchValue);
  }

  Future<bool> controlPumpSoilSettingUsecase(String deviceId, int minSoilSetting, int maxSoilSetting) async {
    return await repository.controlPumpSoilSettingImpl(deviceId, minSoilSetting, maxSoilSetting);
  }

  Future<Map<String, dynamic>> getSoilSettingUsecase(String deviceId) async {
    return await repository.getSoilSettingImpl(deviceId);
  }
}