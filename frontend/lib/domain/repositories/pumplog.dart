abstract class PumplogRepository {
  Future<Map<String, dynamic>> getQuickActivityImpl(String devideId);
  Future<Map<String, dynamic>> getWaterFlowActivityImpl(
    String devideId,
    bool isToday,
    bool isLastDay,
    bool isThisMonth,
    String startDate,
    String endDate,
  );
}