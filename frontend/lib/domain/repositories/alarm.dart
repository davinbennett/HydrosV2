abstract class AlarmRepository {
  Future<Map<String, dynamic>> fetchAlarmImpl(String devideId);
  Future<int> postAlarmImpl(String deviceId, String scheduleTime, int durationOn, int repeatType);
  Future<String> updateEnableAlarmImpl(int alarmId, String deviceId, bool isEnabled);
  Future<String> deleteAlarmImpl(int alarmId, String deviceId);
  Future<String> updateAlarmImpl(
    int alarmId,
    String deviceId,
    String scheduleTime,
    int durationOn,
    int repeatType,
  );
}