import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:zippa_app/core/api_client.dart';
import 'package:zippa_app/core/constants.dart';
import 'package:zippa_app/core/storage.dart';
import 'package:zippa_app/models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  void _setLoading(bool val) {
    print('🔄 _setLoading($val)'); // Added debug print
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String? val) {
    print('⚠️ _setError: $val'); // Added debug print
    _error = val;
    notifyListeners();
  }

  // Register
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await ApiClient.dio.post(
        AppConstants.register,
        data: {
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'confirm_password': confirmPassword,
          'role': role,
        },
      );
      await AppStorage.saveTokens(
        access: res.data['access'],
        refresh: res.data['refresh'],
      );
      await AppStorage.saveRole(res.data['role']);
      _user = User.fromJson(res.data);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _setError(_parseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login({required String email, required String password}) async {
    print('🔵 [login] Called with email: $email');
    _setLoading(true);
    _setError(null);

    try {
      print('📡 [login] Sending POST to ${AppConstants.login}');
      final res = await ApiClient.dio.post(
        AppConstants.login,
        data: {'email': email, 'password': password},
      );
      print('✅ [login] Response received: ${res.statusCode}');
      print('✅ [login] Response data: ${res.data}');

      await AppStorage.saveTokens(
        access: res.data['access'],
        refresh: res.data['refresh'],
      );
      await AppStorage.saveRole(res.data['user']['role']);
      _user = User.fromJson(res.data['user']);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      print('❌ [login] DioException type: ${e.type}');
      print('❌ [login] DioException message: ${e.message}');
      print('❌ [login] Status code: ${e.response?.statusCode}');
      print('❌ [login] Response data: ${e.response?.data}');
      _setError(_parseError(e));
      return false;
    } catch (e, stack) {
      print('💥 [login] Unexpected error: $e');
      print('💥 [login] Stacktrace: $stack');
      _setError('An unexpected error occurred.');
      return false;
    } finally {
      print('⚪️ [login] Finally block, setting loading to false');
      _setLoading(false);
    }
  }

  // Get current user
  Future<void> fetchMe() async {
    _setLoading(true);
    try {
      final res = await ApiClient.dio.get(AppConstants.me);
      _user = User.fromJson(res.data);
      notifyListeners();
    } on DioException catch (e) {
      _setError(_parseError(e));
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final refresh = await AppStorage.getRefreshToken();
      await ApiClient.dio.post(AppConstants.logout, data: {'refresh': refresh});
    } catch (_) {}
    await AppStorage.clear();
    _user = null;
    notifyListeners();
  }

  // Parse Dio errors
  String _parseError(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      if (data.containsKey('detail')) return data['detail'];
      final first = data.values.first;
      if (first is List) return first.first.toString();
      return first.toString();
    }
    return 'Something went wrong. Please try again.';
  }
}
