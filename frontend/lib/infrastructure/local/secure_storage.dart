import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyUserId = 'user_id';
  static const _keyDeviceId = 'device_id';
  static const _keyHasPlant = 'hasPlant';
  static const _pairedAt = 'paired_at';

  // Access Token
  static Future<void> saveAccessToken(String token) async =>
      await _storage.write(key: _keyAccessToken, value: token);

  static Future<String?> getAccessToken() async =>
      await _storage.read(key: _keyAccessToken);

  static Future<void> deleteAccessToken() async =>
      await _storage.delete(key: _keyAccessToken);

  // User ID
  static Future<void> saveUserId(String userId) async =>
      await _storage.write(key: _keyUserId, value: userId);

  static Future<String?> getUserId() async =>
      await _storage.read(key: _keyUserId);

  static Future<void> deleteUserId() async =>
      await _storage.delete(key: _keyUserId);

  // Device ID
  static Future<void> saveDeviceId(String deviceId) async =>
      await _storage.write(key: _keyDeviceId, value: deviceId);

  static Future<String?> getDeviceId() async =>
      await _storage.read(key: _keyDeviceId);

  static Future<void> deleteDeviceId() async =>
      await _storage.delete(key: _keyDeviceId);

  // Paired At
  static Future<void> savePairedAt(String time) async =>
      await _storage.write(key: _pairedAt, value: time);

  static Future<String?> getPairedAt() async =>
      await _storage.read(key: _pairedAt);

  static Future<void> deletePairedAt() async =>
      await _storage.delete(key: _pairedAt);

  // Have Plant
  static Future<void> saveHasPlant(bool hasPlant) async {
    await _storage.write(key: _keyHasPlant, value: hasPlant ? 'true' : 'false');
  }
  static Future<bool> getHasPlant() async {
    final value = await _storage.read(key: _keyHasPlant);
    return value == 'true';
  }
  static Future<void> deleteHasPlant() async {
    await _storage.delete(key: _keyHasPlant);
  }

  // Clear All
  static Future<void> clearAll() async => await _storage.deleteAll();
}
