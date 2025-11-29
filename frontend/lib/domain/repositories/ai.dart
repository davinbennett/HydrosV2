abstract class AIRepository {
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
  );
}
