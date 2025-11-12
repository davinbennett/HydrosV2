
abstract class DeviceRepository {
  Future<bool> pairDevice(String code, int userId);
  Future<bool> controlPumpSwitchImpl(String devideId, bool switchValue);
}