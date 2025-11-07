
import 'package:frontend/domain/entities/sensor.dart';

abstract class SensorRepository {
  Stream<SensorEntity> getSensorStream(String deviceId);
  Future<void> stop(String deviceId);
}