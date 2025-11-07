import 'dart:async';

import 'package:frontend/domain/entities/sensor.dart';
import 'package:frontend/domain/repositories/sensor.dart';
import 'package:frontend/infrastructure/websocket/sensor_websocket.dart';

import '../../core/utils/logger.dart';

class SensorImpl implements SensorRepository {
  final WebsocketService websocket;
  final Map<String, StreamController<SensorEntity>> _controllers = {};

  SensorImpl({required this.websocket});

  @override
  Stream<SensorEntity> getSensorStream(String deviceId) {
    // Jika sudah ada stream untuk device ini, return saja
    if (_controllers.containsKey(deviceId)) {
      return _controllers[deviceId]!.stream;
    }

    final controller = StreamController<SensorEntity>.broadcast();
    _controllers[deviceId] = controller;

    websocket.listen(deviceId, (event) {
      logger.i("📡 [WS EVENT RECEIVED] Device $deviceId -> $event");
      
      final sensor = SensorEntity(
        temperature: (event['temperature'] ?? 0).toDouble(),
        humidity: (event['humidity'] ?? 0).toDouble(),
        soil: (event['soil'] ?? 0).toDouble(),
      );

      controller.add(sensor);
    });


    return controller.stream;
  }

  @override
  Future<void> stop(String deviceId) async {
    websocket.stopListening(deviceId);
    await _controllers[deviceId]?.close();
    _controllers.remove(deviceId);
  }
}
