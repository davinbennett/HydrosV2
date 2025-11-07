import 'package:frontend/domain/entities/sensor.dart';
import 'package:frontend/domain/repositories/sensor.dart';

class GetSensorStreamUsecase {
  final SensorRepository repository;

  GetSensorStreamUsecase(this.repository);

  Stream<SensorEntity> execute(String deviceId) {
    return repository.getSensorStream(deviceId);
  }

  Future<void> stop(String deviceId) {
    return repository.stop(deviceId);
  }
}
