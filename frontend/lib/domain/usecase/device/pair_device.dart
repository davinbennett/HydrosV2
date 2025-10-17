import 'package:frontend/domain/repositories/device.dart';

class PairDeviceUsecase {
  final DeviceRepository repository;

  PairDeviceUsecase(this.repository);

  Future<bool> execute(String code, int userId) async {
    return await repository.pairDevice(code, userId);
  }
}