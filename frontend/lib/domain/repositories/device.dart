
abstract class DeviceRepository {
  Future<bool> pairDevice(String code, int userId);
  Future<bool> controlPumpSwitchImpl(String devideId, bool switchValue);
  Future<bool> controlPumpSoilSettingImpl(String devideId, int minSoilSetting, int maxSoilSetting);
  Future<Map<String, dynamic>> getSoilSettingImpl(String devideId);
}