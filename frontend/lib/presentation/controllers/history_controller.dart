import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecase/pumplog.dart';
import '../../domain/usecase/sensor_aggregated.dart';

class HistoryController {
  final SensorAggregatedUsecase sensorAggregatedUsecase;
  final PumplogUsecase pumplogUsecase;
  final Ref ref;

  HistoryController({
    required this.sensorAggregatedUsecase,
    required this.pumplogUsecase,
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

  Future<Map<String, dynamic>> getWaterFlowActivityController(
    String deviceId,
    bool isToday,
    bool isLastDay,
    bool isThisMonth,
    String startDate,
    String endDate,
  ) async {
    final data = await pumplogUsecase.getWaterFlowActivityUsecase(
      deviceId,
      isToday,
      isLastDay,
      isThisMonth,
      startDate,
      endDate,
    );

    if (data["detail"] == []) {
      return {
        "total_pump": 0,
        "average_duration": 0.0,
        "detail": [],
        "chart_frequency": List.filled(6, 0.0),
      };
    }

    final totalPump = data['total_pump'] ?? 0;

    // average_duration
    final rawAvg = data['average_duration'];
    final avgDurationRaw = double.tryParse(rawAvg.toString()) ?? 0.0;
    final avgDuration = double.parse(avgDurationRaw.toStringAsFixed(1));

    final details = data['detail'] ?? [];

    final List<double> chart = List.filled(6, 0.0);

    for (var item in details) {
      final startTimeStr = item['start_time'];
      if (startTimeStr == null) continue;

      DateTime? startTime;

      try {
        startTime = DateTime.parse(startTimeStr);
      } catch (_) {
        continue;
      }

      final hour = startTime.hour;

      if (hour >= 0 && hour <= 3) {
        chart[0] += 1;
      } else if (hour >= 4 && hour <= 7) {
        chart[1] += 1;
      } else if (hour >= 8 && hour <= 11) {
        chart[2] += 1;
      } else if (hour >= 12 && hour <= 15) {
        chart[3] += 1;
      } else if (hour >= 16 && hour <= 19) {
        chart[4] += 1;
      } else if (hour >= 20 && hour <= 23) {
        chart[5] += 1;
      }
    }

    return {
      "total_pump": totalPump,
      "average_duration": avgDuration,
      "chart_frequency": chart,
      "detail": details,
    };
  }
}
