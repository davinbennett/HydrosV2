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

  @override
  Future<String> addPlantImpl(
    String? deviceId,
    String? plantName,
    String? progressPlan,
    String? longitude,
    String? latitude,
    String? location,
  ){
    return api.addPlantApi(deviceId, plantName, progressPlan, longitude, latitude, location);
  }

  @override
  Future<Map<String, dynamic>> getLocationImpl(String deviceId) {
    return api.getLocationApi(deviceId);
  }

  @override
  Future<Map<String, dynamic>> getWeatherImpl(String devideId) {
    return api.getWeatherApi(devideId);
  }

  @override
  Future<Map<String, dynamic>> getPlantInfoImpl(String devideId) {
    return api.getPlantInfoApi(devideId);
  }
}
