import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyUserId = 'user_id';
  static const _keyDeviceId = 'device_id';
  static const _keyDeviceUid = 'device_uid';
  static const _keyHasPlant = 'hasPlant';
  static const _pairedAt = 'paired_at';
  static const _keyIsNotifOn = 'is_notif_on';

  // Access Token 
  static Future<void> saveAccessToken(String token) async =>
      await _storage.write(key: _keyAccessToken, value: token);

  static Future<String?> getAccessToken() async =>
      await _storage.read(key: _keyAccessToken);

  static Future<void> deleteAccessToken() async =>
      await _storage.delete(key: _keyAccessToken);

  // SAVE NOTIF
  static Future<void> saveIsNotifOn(bool value) async {
    await _storage.write(key: _keyIsNotifOn, value: value ? "1" : "0");
  }

  // GET NOTIF
  static Future<bool> getIsNotifOn() async {
    final result = await _storage.read(key: _keyIsNotifOn);
    return result == "1"; // default ON jika belum ada
  }

  // DELETE NOTIF
  static Future<void> deleteIsNotifOn() async {
    await _storage.delete(key: _keyIsNotifOn);
  }


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

  // Device UID
  
  static Future<void> saveDeviceUId(String deviceUid) async {
      if (deviceUid.isEmpty) {
        throw Exception('Device UID tidak boleh kosong');
      }

      // CEK APAKAH SUDAH ADA
      final existing = await _storage.read(key: _keyDeviceUid);

      if (existing != null && existing.isNotEmpty) {
        // Jika sama, tidak perlu overwrite
        if (existing == deviceUid) {
          return;
        }

        // Jika berbeda, overwrite secara aman
        await _storage.delete(key: _keyDeviceUid);
      }

      // SIMPAN BARU
      await _storage.write(key: _keyDeviceUid, value: deviceUid);
    }

  static Future<String?> getDeviceUId() async =>
      await _storage.read(key: _keyDeviceUid);

  static Future<void> deleteDeviceUId() async =>
      await _storage.delete(key: _keyDeviceUid);

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
