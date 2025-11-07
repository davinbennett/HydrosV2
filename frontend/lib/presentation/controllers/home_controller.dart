import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/domain/entities/sensor.dart';
import 'package:frontend/domain/usecase/device/sensor_stream.dart';
import 'package:frontend/presentation/providers/device_provider.dart';
import 'package:frontend/presentation/states/device_state.dart';

class HomeController extends StateNotifier<Map<String, dynamic>> {
    final GetSensorStreamUsecase getSensorStreamUsecase;
  final Ref ref;
  StreamSubscription<SensorEntity>? _sub;

  HomeController(this.getSensorStreamUsecase, this.ref) : super({});

  Future<void> init() async {
    final deviceState = ref.read(deviceProvider);
    final activePair = deviceState.activePairState;

    if (activePair == null) {
      logger.i('🚫 No paired device — skip WebSocket');
      return;
    }

    String deviceId = '';
    if (activePair is PairedNoPlant) {
      deviceId = activePair.deviceId;
    } else if (activePair is PairedWithPlant) {
      deviceId = activePair.deviceId;
    }

    await getDataSensor(deviceId);
  }

  /// Listen sensor realtime
  Future<void> getDataSensor(String deviceId) async {
    await _sub?.cancel();

    _sub = getSensorStreamUsecase.execute(deviceId).listen((sensor) {
      state = {
        'data': {
          'temperature': sensor.temperature,
          'humidity': sensor.humidity,
          'soil': sensor.soil,
        },
      };
    });
  }

  /// Stop listener
  Future<void> stopSensorListener() async {
    await _sub?.cancel();
    _sub = null;
  }
}
