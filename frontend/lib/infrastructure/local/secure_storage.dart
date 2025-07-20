import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyUserId = 'user_id';
  static const _keyDeviceId = 'device_id';

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

  // Clear All
  static Future<void> clearAll() async => await _storage.deleteAll();
}
