import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  static const _storage = FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey = 'user_role';

  // Save tokens
  static Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  // Get tokens
  static Future<String?> getAccessToken() async =>
      await _storage.read(key: _accessKey);
  static Future<String?> getRefreshToken() async =>
      await _storage.read(key: _refreshKey);

  // Save role
  static Future<void> saveRole(String role) async =>
      await _storage.write(key: _roleKey, value: role);
  static Future<String?> getRole() async => await _storage.read(key: _roleKey);

  // Clear all on logout
  static Future<void> clear() async => await _storage.deleteAll();
}
