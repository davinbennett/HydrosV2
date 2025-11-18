
import 'package:frontend/domain/entities/sensor.dart';

abstract class SensorRepository {
  Stream<SensorEntity> getSensorStream(String deviceId);
  Future<void> stop(String deviceId);
  Future<Map<String, dynamic>> getSensorAggregatedImpl(String devideId, bool isToday, bool isLastDay, bool isThisMonth, String startDate, String endDate);
}