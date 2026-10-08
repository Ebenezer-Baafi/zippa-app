import 'package:dio/dio.dart';
import 'package:zippa_app/core/constants.dart';
import 'package:zippa_app/core/storage.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get dio => _dio;

  // Prevent duplicate interceptors on hot reload
  static bool _initialized = false;

  // Add auth interceptor
  static void init() {
    if (_initialized) return;
    _initialized = true;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AppStorage.getAccessToken();

          // Debug print — remove once login works end-to-end
          final preview = token == null
              ? 'NULL'
              : (token.length > 20 ? token.substring(0, 20) : token);
          print('🔐 ${options.method} ${options.uri} | token=$preview');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Debug print — helps identify failed requests
          print(
            '${error.requestOptions.method} '
            '${error.requestOptions.uri} → '
            '${error.response?.statusCode} ${error.response?.data}',
          );
          return handler.next(error);
        },
      ),
    );
  }
}
