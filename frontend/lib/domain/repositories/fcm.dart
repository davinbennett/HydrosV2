abstract class FcmRepository {
  Future<String> sendTokenToBackendImpl(
    String? token,
    String? deviceId,
  );
}
