import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/models/user.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthRepository({Dio? dio, TokenStorage? tokenStorage})
      : _dio = (dio ?? ApiClient().dio),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<User> signup({
    required String email,
    required String username,
    required String displayName,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/signup', data: {
        'email': email,
        'username': username,
        'displayName': displayName,
        'password': password,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      await _tokenStorage.saveToken(token);
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      await _tokenStorage.saveToken(token);
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      final data = response.data['data'] as Map<String, dynamic>;
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // ignore network errors on logout
    }
    await _tokenStorage.clearToken();
  }

  AuthException _handleError(DioException e) {
    final response = e.response;
    if (response == null) {
      return AuthException('No internet connection or server unreachable.');
    }

    final data = response.data;
    String message = 'Something went wrong';

    if (data is Map<String, dynamic>) {
      // Validation errors: { errors: { field: ["..."] } }
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstField = errors.entries.first;
        final firstError = (firstField.value as List).first;
        message = '${firstField.key}: $firstError';
      } else if (data['message'] is String) {
        message = data['message'] as String;
      }
    }

    return AuthException(message, statusCode: response.statusCode);
  }
}