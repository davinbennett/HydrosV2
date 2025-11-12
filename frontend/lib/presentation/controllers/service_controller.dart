import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecase/device/control_pump.dart';

class ServiceController {
  final ControlPumpUsecase controlPumpUsecase;
  final Ref ref;

  ServiceController({required this.controlPumpUsecase, required this.ref});

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
    int maxSoilSetting
  ) async {
    return await controlPumpUsecase.controlPumpSoilSettingUsecase(
      deviceId,
      minSoilSetting,
      maxSoilSetting
    );
  }

  Future<Map<String, dynamic>> getSoilSettingController(
    String deviceId,
  ) async {
    return await controlPumpUsecase.getSoilSettingUsecase(
      deviceId
    );
  }
}
