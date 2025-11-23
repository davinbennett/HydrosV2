
abstract class DeviceRepository {
  Future<bool> pairDevice(String code, int userId);
  Future<bool> controlPumpSwitchImpl(String devideId, bool switchValue);
  Future<bool> controlPumpSoilSettingImpl(String devideId, int minSoilSetting, int maxSoilSetting);
  Future<Map<String, dynamic>> getSoilSettingImpl(String devideId);
  Future<String> addPlantImpl(
    String? deviceId,
    String? plantName,
    String? progressPlan,
    String? longitude,
    String? latitude,
    String? location,
  );
  Future<Map<String, dynamic>> getLocationImpl(String deviceId);
  Future<Map<String, dynamic>> getWeatherImpl(String deviceId);
  Future<Map<String, dynamic>> getPlantInfoImpl(String deviceId);
}