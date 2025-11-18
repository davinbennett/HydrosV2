import '../repositories/sensor.dart';

class SensorAggregatedUsecase {
  final SensorRepository repository;

  SensorAggregatedUsecase(this.repository);

  Future<Map<String, dynamic>> getSensorAggregatedUsecase(
    String deviceId,
    bool isToday,
    bool isLastDay,
    bool isThisMonth,
    String startDate,
    String endDate,
  ) async {
    return await repository.getSensorAggregatedImpl(
      deviceId,
      isToday,
      isLastDay,
      isThisMonth,
      startDate,
      endDate,
    );
  }
}
