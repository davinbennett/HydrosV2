import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/alarm.dart';
import 'package:frontend/domain/usecase/pumplog.dart';

import '../../domain/usecase/device/control_pump.dart';

class ServiceController {
  final ControlPumpUsecase controlPumpUsecase;
  final AlarmUsecase alarmUsecase;
  final PumplogUsecase pumplogUsecase;
  final Ref ref;

  ServiceController({
    required this.alarmUsecase,
    required this.controlPumpUsecase,
    required this.pumplogUsecase,
    required this.ref,
  });

  Future<bool> controlPumpSwitchController(
    String deviceId,
    bool switchValue,
  ) async {
    return await controlPumpUsecase.controlPumpSwitchUsecase(
      deviceId,
      switchValue,
    );
  }

  Future<bool> controlPumpSoilSettingController(
    String deviceId,
    int minSoilSetting,
    int maxSoilSetting,
  ) async {
    return await controlPumpUsecase.controlPumpSoilSettingUsecase(
      deviceId,
      minSoilSetting,
      maxSoilSetting,
    );
  }

  Future<Map<String, dynamic>> getSoilSettingController(String deviceId) async {
    return await controlPumpUsecase.getSoilSettingUsecase(deviceId);
  }

  Future<Map<String, dynamic>> fetchAlarmController(String deviceId) async {
    final data = await alarmUsecase.fetchAlarmUsecase(deviceId);

    return data;
  }

  Future<Map<String, dynamic>> getQuickActivityController(String deviceId) async {
    return await pumplogUsecase.getQuickActivityUsecase(deviceId);
  }
}
