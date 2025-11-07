import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/impl/sensor.dart';
import 'package:frontend/domain/repositories/sensor.dart';
import 'package:frontend/domain/usecase/device/sensor_stream.dart';
import 'package:frontend/infrastructure/websocket/sensor_websocket.dart';
import 'package:frontend/presentation/controllers/home_controller.dart';

final websocketServiceProvider = Provider<WebsocketService>((ref) {
  return WebsocketService();
});


// Repo Provider
final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  final websocket = ref.watch(websocketServiceProvider);
  return SensorImpl(websocket: websocket);
});

// Usecase Provider
final getSensorStreamUsecaseProvider = Provider(
  (ref) => GetSensorStreamUsecase(ref.watch(sensorRepositoryProvider)),
);

// Controller Provider
final homeControllerProvider =
    StateNotifierProvider<HomeController, Map<String, dynamic>>(
      (ref) => HomeController(ref.watch(getSensorStreamUsecaseProvider), ref),
    );
