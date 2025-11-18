
import '../repositories/pumplog.dart';

class PumplogUsecase {
  final PumplogRepository repository;

  PumplogUsecase(this.repository);

  Future<Map<String, dynamic>> getQuickActivityUsecase(String deviceId) async {
    return await repository.getQuickActivityImpl(deviceId);
  }
}