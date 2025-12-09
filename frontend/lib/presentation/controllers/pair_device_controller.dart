import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/device/pair_device.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/states/device_state.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class PairDeviceController {
  final PairDeviceUsecase pairDeviceUsecase;
  final Ref ref;
  
  PairDeviceController({required this.pairDeviceUsecase , required this.ref});

  Future<DevicePairState> pairDevice(String code, int userId) async {
    try {
      await pairDeviceUsecase.execute(code, userId);

      final now = DateTime.now();
      final formatted = DateFormat('dd-MM-yyyy HH:mm').format(now);

      await SecureStorage.saveDeviceId(code);
      await SecureStorage.savePairedAt(formatted);

      return PairedNoPlant(code);
    } catch (e) {
      return DevicePairFailure(e.toString());
    }
  }
}