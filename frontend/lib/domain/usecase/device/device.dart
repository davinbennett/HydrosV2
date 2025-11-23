import '../../repositories/device.dart';

class DeviceUsecase {
  final DeviceRepository repository;

  DeviceUsecase(this.repository);

  Future<String> addPlantUsecase(
    String? deviceId,
    String? plantName,
    String? progressPlan,
    String? longitude,
    String? latitude,
    String? location,
  ) async {
    return await repository.addPlantImpl(
      deviceId,
      plantName,
      progressPlan,
      longitude,
      latitude,
      location,
    );
  }

  Future<Map<String, dynamic>> getLocationUsecase(String deviceId) async {
    return await repository.getLocationImpl(deviceId);
  }

  Future<Map<String, dynamic>> getWeatherUsecase(String deviceId) async {
    return await repository.getWeatherImpl(deviceId);
  }

  Future<Map<String, dynamic>> getPlantInfoUsecase(String deviceId) async {
    return await repository.getPlantInfoImpl(deviceId);
  }
}