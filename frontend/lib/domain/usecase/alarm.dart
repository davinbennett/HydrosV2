import '../repositories/alarm.dart';

class AlarmUsecase {
  final AlarmRepository repository;

  AlarmUsecase(this.repository);

  Future<Map<String, dynamic>> fetchAlarmUsecase(String deviceId) async {
    return await repository.fetchAlarmImpl(deviceId);
  }

  Future<int> postAlarmUsecase(
    String deviceId,
    String scheduleTime,
    int durationOn,
    int repeatType,
  ) async {
    return await repository.postAlarmImpl(deviceId, scheduleTime, durationOn, repeatType);
  }

  Future<String> updateEnableAlarmUsecase(
    int alarmId,
    String deviceId,
    bool isEnabled,
  ) async {
    return await repository.updateEnableAlarmImpl( alarmId, deviceId, isEnabled);
  }

  Future<String> deleteAlarmUsecase(int alarmId, String deviceId) async {
    return await repository.deleteAlarmImpl(alarmId, deviceId);
  }

  Future<String> updateAlarmUsecase(
    int alarmId,
    String deviceId,
    String scheduleTime,
    int durationOn,
    int repeatType,
  ) async {
    return await repository.updateAlarmImpl(
      alarmId,
      deviceId,
      scheduleTime,
      durationOn,
      repeatType,
    );
  }
}