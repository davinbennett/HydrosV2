import 'package:frontend/domain/entities/sensor.dart';

import '../../domain/repositories/sensor.dart';
import '../../infrastructure/api/sensor_aggregated_api.dart';

class SensorImpl implements SensorRepository {
  final SensorAggregatedApi api;
  SensorImpl({required this.api});

  @override
  Future<Map<String, dynamic>> getSensorAggregatedImpl(
    String devideId,
    bool isToday,
    bool isLastDay,
    bool isThisMonth,
    String startDate,
    String endDate,
  ) {
    return api.getSensorAggregatedApi(
      devideId,
      isToday,
      isLastDay,
      isThisMonth,
      startDate,
      endDate,
    );
  }

  @override
  Stream<SensorEntity> getSensorStream(String deviceId) {
    throw UnimplementedError();
  }

  @override
  Future<void> stop(String deviceId) {
    throw UnimplementedError();
  }
}
