import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/poem.dart';

class PoemsException implements Exception {
  final String message;
  final int? statusCode;
  PoemsException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class PoemFeedResult {
  final List<Poem> poems;
  final String? nextCursor;

  const PoemFeedResult({required this.poems, this.nextCursor});
}

class PoemsRepository {
  final Dio _dio;

  PoemsRepository({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  Future<PoemFeedResult> listPoems({String? cursor, int limit = 10}) async {
    try {
      final response = await _dio.get('/poems', queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      final list = data['poems'] as List<dynamic>;
      final poems = list
          .map((j) => Poem.fromJson(j as Map<String, dynamic>))
          .toList();
      final nextCursor = data['nextCursor'] as String?;
      return PoemFeedResult(poems: poems, nextCursor: nextCursor);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<Poem> getPoem(String id) async {
    try {
      final response = await _dio.get('/poems/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return Poem.fromJson(data['poem'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<Poem> createPoem({
    String? title,
    required String content,
    required PoemLanguage language,
    PoemEmotion? emotion,
    String? theme,
  }) async {
    try {
      final response = await _dio.post('/poems', data: {
        if (title != null && title.isNotEmpty) 'title': title,
        'content': content,
        'language': language.apiValue,
        if (emotion != null) 'emotion': emotion.apiValue,
        if (theme != null && theme.isNotEmpty) 'theme': theme,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      return Poem.fromJson(data['poem'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  PoemsException _handle(DioException e) {
    final response = e.response;
    if (response == null) {
      return PoemsException('Cannot reach Syaahi. Check your connection.');
    }
    final data = response.data;
    String message = 'Something went wrong';
    if (data is Map<String, dynamic>) {
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstField = errors.entries.first;
        final firstError = (firstField.value as List).first;
        message = '${firstField.key}: $firstError';
      } else if (data['message'] is String) {
        message = data['message'] as String;
      }
    }
    return PoemsException(message, statusCode: response.statusCode);
  }
}