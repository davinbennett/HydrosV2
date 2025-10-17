import 'package:frontend/domain/repositories/device.dart';
import 'package:frontend/infrastructure/api/device_api.dart';

class DeviceImpl implements DeviceRepository {
  final DeviceApi api;
  DeviceImpl({required this.api});

  @override
  Future<bool> pairDevice(String code, int userId) {
    return api.pairDeviceApi(code: code, userId: userId);
  }

}