import '../../domain/repositories/ai.dart';
import '../../infrastructure/api/ai_api.dart';

class AIImpl implements AIRepository {
  final AIApi api;
  AIImpl({required this.api});

  @override
  Future<Map<String, dynamic>> postAiReportImpl(
    String? plantName,
    int? progressPlan,
    int? progressNow,
    String? longitude,
    String? latitude,
    double? temperature,
    double? soil,
    double? humidity,
    int? pumpUsage,
    String? lastWatered,
    String? time,
  ) {
    return api.postAiReportApi(
      plantName,
      progressPlan,
      progressNow,
      longitude,
      latitude,
      temperature,
      soil,
      humidity,
      pumpUsage,
      lastWatered,
      time,
    );
  }
}
