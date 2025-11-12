import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecase/device/control_pump.dart';

class ServiceController {
  final ControlPumpUsecase controlPumpUsecase;
  final Ref ref;
  
  ServiceController({required this.controlPumpUsecase , required this.ref});

  Future<String> controlPumpSwitchController(String deviceId, bool switchValue) async {
    try {
      var result = await controlPumpUsecase.controlPumpSwitchUsecase(deviceId, switchValue);


      return result ? 'true' : 'false';
    } catch (e) {
      return e.toString();
    }
  }
}