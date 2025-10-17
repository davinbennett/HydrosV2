import 'package:frontend/domain/usecase/device/pair_device.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/states/device_state.dart';

class PairDeviceController {
  final PairDeviceUsecase pairDeviceUsecase;
  PairDeviceController({required this.pairDeviceUsecase});

  Future<DevicePairState> pairDevice(String code, int userId) async {
    try {
      await pairDeviceUsecase.execute(code, userId);

      await SecureStorage.saveDeviceId(code);

      return PairedNoPlant(int.parse(code));
    } catch (e) {
      return DevicePairFailure(e.toString());
    }
  }
}