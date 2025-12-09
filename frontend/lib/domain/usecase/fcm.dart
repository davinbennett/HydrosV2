
import '../repositories/fcm.dart';

class FcmUsecase {
  final FcmRepository repository;

  FcmUsecase(this.repository);

  Future<String> sendTokenToBackendUsecase(
    String? token,
    String? deviceId,
  ) async {
    return await repository.sendTokenToBackendImpl(
      token, deviceId,
    );
  }
}
