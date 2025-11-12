import 'package:frontend/domain/repositories/device.dart';
import 'package:frontend/infrastructure/api/device_api.dart';

class DeviceImpl implements DeviceRepository {
  final DeviceApi api;
  DeviceImpl({required this.api});

  @override
  Future<bool> pairDevice(String code, int userId) {
    return api.pairDeviceApi(code: code, userId: userId);
  }

  @override
  Future<bool> controlPumpSwitchImpl(String devideId, bool switchValue) {
    return api.controlPumpSwitchApi(
      devideId: devideId,
      switchValue: switchValue,
    );
  }

  @override
  Future<bool> controlPumpSoilSettingImpl(String devideId, int minSoilSetting, int maxSoilSetting) {
    return api.controlPumpSoilSettingApi(
      devideId: devideId,
      minSoilSetting: minSoilSetting,
      maxSoilSetting: maxSoilSetting,
    );
  }

  @override
  Future<Map<String, dynamic>> getSoilSettingImpl(String devideId) {
    return api.getSoilSettingApi(devideId: devideId);
  }
}
