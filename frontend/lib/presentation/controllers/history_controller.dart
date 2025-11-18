import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecase/sensor_aggregated.dart';

class HistoryController {
  final SensorAggregatedUsecase sensorAggregatedUsecase;
  final Ref ref;

  HistoryController({
    required this.sensorAggregatedUsecase,
    required this.ref,
  });

  Future<Map<String, dynamic>> getSensorAggregatedController(
    String deviceId,
    bool isToday,
    bool isLastDay,
    bool isThisMonth,
    String startDate,
    String endDate,
  ) async {
    return await sensorAggregatedUsecase.getSensorAggregatedUsecase(
      deviceId,
      isToday,
      isLastDay,
      isThisMonth,
      startDate,
      endDate,
    );
  }
}
