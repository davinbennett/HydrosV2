
import '../repositories/pumplog.dart';

class PumplogUsecase {
  final PumplogRepository repository;

  PumplogUsecase(this.repository);

  Future<Map<String, dynamic>> getQuickActivityUsecase(String deviceId) async {
    return await repository.getQuickActivityImpl(deviceId);
  }

  Future<Map<String, dynamic>> getWaterFlowActivityUsecase(
    String deviceId,
    bool isToday,
    bool isLastDay,
    bool isThisMonth,
    String startDate,
    String endDate,
  ) async {
    return await repository.getWaterFlowActivityImpl(
      deviceId,
      isToday,
      isLastDay,
      isThisMonth,
      startDate,
      endDate,
    );
  }

  Future<Map<String, dynamic>> getPumpUsageUsecase(String deviceId) async {
    return await repository.getPumpUsageImpl(deviceId);
  }

  Future<Map<String, dynamic>> getLastWateredUsecase(String deviceId) async {
    return await repository.getLastWateredImpl(deviceId);
  }
}