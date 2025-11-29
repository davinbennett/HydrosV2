import '../repositories/ai.dart';

class AIUsecase {
  final AIRepository repository;

  AIUsecase(this.repository);

  Future<Map<String, dynamic>> postAiReportUsecase(
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
  ) async {
    return await repository.postAiReportImpl(
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
