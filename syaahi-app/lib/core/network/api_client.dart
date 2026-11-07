import 'package:dio/dio.dart';
import '../constants/strings.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient({TokenStorage? tokenStorage}) : _tokenStorage = tokenStorage ?? TokenStorage() {
    _dio = Dio(BaseOptions(
      baseUrl: SyaahiStrings.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // FIX (UX-06.M1): TokenStorage.getToken() can hang or throw on
        // Flutter Web (FlutterSecureStorage / localStorage race condition).
        // We MUST always call handler.next() — otherwise the request stalls
        // indefinitely and the reader shows "Opening poem..." forever.
        try {
          final token = await _tokenStorage.getToken()
              .timeout(const Duration(seconds: 3));
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // Token retrieval failed or timed out.
          // Proceed without Authorization header (guest/public request).
          // Do NOT swallow this silently in production — log in debug mode.
          assert(() {
            // ignore: avoid_print
            print('[ApiClient] Token retrieval failed; proceeding as guest.');
            return true;
          }());
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Centralized error logging hook
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
}
