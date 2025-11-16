import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/alarm.dart';

class AlarmController {
  final AlarmUsecase alarmUsecase;
  final Ref ref;

  AlarmController({required this.alarmUsecase, required this.ref});

  Future<int> postAlarmController(
    String deviceId,
    String scheduleTime,
    int durationOn,
    int repeatType,
  ) async {
    final data = await alarmUsecase.postAlarmUsecase(
      deviceId,
      scheduleTime,
      durationOn,
      repeatType,
    );

    return data;
  }

  Future<String> updateEnableAlarmController(
    int alarmId,
    String deviceId,
    bool isEnabled,
  ) async {
    final data = await alarmUsecase.updateEnableAlarmUsecase(
      alarmId,
      deviceId,
      isEnabled,
    );

    return data;
  }

  Future<String> deleteAlarmController(int alarmId, String deviceId) async {
    final data = await alarmUsecase.deleteAlarmUsecase(alarmId, deviceId);

    return data;
  }

  Future<String> updateAlarmController(
    int alarmId,
    String deviceId,
    String scheduleTime,
    int durationOn,
    int repeatType,
  ) async {
    final data = await alarmUsecase.updateAlarmUsecase(
      alarmId,
      deviceId,
      scheduleTime,
      durationOn,
      repeatType,
    );

    return data;
  }
}
