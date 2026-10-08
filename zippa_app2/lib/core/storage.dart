import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  static const _storage = FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey = 'user_role';

  // ── In-memory cache ──────────────────────────────────────────
  // Guarantees the token is available immediately after saveTokens()
  // without waiting for a disk read on every request.
  static String? _cachedAccessToken;
  static String? _cachedRefreshToken;
  static String? _cachedRole;

  // Save tokens
  static Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    _cachedAccessToken = access; // in-memory first
    _cachedRefreshToken = refresh;
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  // Get tokens — prefer memory, fall back to disk
  static Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _storage.read(key: _accessKey);
    return _cachedAccessToken;
  }

  static Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    _cachedRefreshToken = await _storage.read(key: _refreshKey);
    return _cachedRefreshToken;
  }

  // Save / read role
  static Future<void> saveRole(String role) async {
    _cachedRole = role;
    await _storage.write(key: _roleKey, value: role);
  }

  static Future<String?> getRole() async {
    if (_cachedRole != null) return _cachedRole;
    _cachedRole = await _storage.read(key: _roleKey);
    return _cachedRole;
  }

  // Clear all on logout
  static Future<void> clear() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedRole = null;
    await _storage.deleteAll();
  }
}
