import 'package:frontend/domain/repositories/alarm.dart';

import '../../infrastructure/api/alarm_api.dart';

class AlarmImpl implements AlarmRepository {
  final AlarmApi api;
  AlarmImpl({required this.api});

  @override
  Future<Map<String, dynamic>> fetchAlarmImpl(String devideId) {
    return api.fetchAlarmApi(devideId);
  }

  @override
  Future<int> postAlarmImpl(String deviceId, String scheduleTime, int durationOn, int repeatType) {
    return api.postAlarmApi(deviceId, scheduleTime, durationOn, repeatType);
  }

  @override
  Future<String> updateEnableAlarmImpl(int alarmId, String deviceId, bool isEnabled) {
    return api.updateEnableAlarmApi(alarmId, deviceId, isEnabled);
  }

  @override
  Future<String> deleteAlarmImpl(int alarmId, String deviceId) {
    return api.deleteAlarmApi(alarmId, deviceId);
  }

  @override
  Future<String> updateAlarmImpl(
    int alarmId,
    String deviceId,
    String scheduleTime,
    int durationOn,
    int repeatType,
  ) {
    return api.updateAlarmApi(
      alarmId, deviceId, scheduleTime, durationOn, repeatType);
  }

}