import '../../domain/repositories/fcm.dart';
import '../../infrastructure/api/fcm_api.dart';

class FcmImpl implements FcmRepository {
  final FcmApi api;
  FcmImpl({required this.api});

  @override
  Future<String> sendTokenToBackendImpl(
    String? token, 
    String? deviceId,
  ) {
    return api.sendTokenToBackendApi(
      token,
      deviceId,
    );
  }
}
