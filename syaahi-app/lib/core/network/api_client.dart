import 'package:dio/dio.dart';
import '../constants/strings.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: SyaahiStrings.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
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