import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/poem.dart';

class ResonanceException implements Exception {
  final String message;
  final int? statusCode;
  ResonanceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ResonanceReplyModel {
  final String id;
  final String responseId;
  final String authorId;
  final String content;
  final PoemAuthor author;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ResonanceReplyModel({
    required this.id,
    required this.responseId,
    required this.authorId,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResonanceReplyModel.fromJson(Map<String, dynamic> json) {
    return ResonanceReplyModel(
      id: json['id'] as String,
      responseId: json['responseId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      content: json['content'] as String,
      author: PoemAuthor.fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ResonanceResponseModel {
  final String id;
  final String poemId;
  final String userId;
  final String content;
  final PoemAuthor user;
  final ResonanceReplyModel? reply;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ResonanceResponseModel({
    required this.id,
    required this.poemId,
    required this.userId,
    required this.content,
    required this.user,
    this.reply,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResonanceResponseModel.fromJson(Map<String, dynamic> json) {
    return ResonanceResponseModel(
      id: json['id'] as String,
      poemId: json['poemId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      user: PoemAuthor.fromJson(json['user'] as Map<String, dynamic>),
      reply: json['reply'] != null
          ? ResonanceReplyModel.fromJson(json['reply'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ResonanceListResult {
  final List<ResonanceResponseModel> responses;
  final String? nextCursor;

  const ResonanceListResult({required this.responses, this.nextCursor});
}

class ResonanceRepository {
  final Dio _dio;

  ResonanceRepository({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  Future<ResonanceListResult> listResponses(
    String poemId, {
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/poems/$poemId/resonances',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final list = data['responses'] as List<dynamic>;
      final responses = list
          .map((j) =>
              ResonanceResponseModel.fromJson(j as Map<String, dynamic>))
          .toList();
      final nextCursor = data['nextCursor'] as String?;
      return ResonanceListResult(responses: responses, nextCursor: nextCursor);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<ResonanceResponseModel> createResponse(
    String poemId,
    String content,
  ) async {
    try {
      final response = await _dio.post(
        '/poems/$poemId/resonances',
        data: {'content': content},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ResonanceResponseModel.fromJson(
        data['response'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<ResonanceResponseModel> updateResponse(
    String responseId,
    String content,
  ) async {
    try {
      final response = await _dio.patch(
        '/resonances/$responseId',
        data: {'content': content},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ResonanceResponseModel.fromJson(
        data['response'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<void> deleteResponse(String responseId) async {
    try {
      await _dio.delete('/resonances/$responseId');
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<ResonanceReplyModel> createReply(
    String responseId,
    String content,
  ) async {
    try {
      final response = await _dio.post(
        '/resonances/$responseId/reply',
        data: {'content': content},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ResonanceReplyModel.fromJson(
        data['reply'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<ResonanceReplyModel> updateReply(
    String replyId,
    String content,
  ) async {
    try {
      final response = await _dio.patch(
        '/resonance-replies/$replyId',
        data: {'content': content},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ResonanceReplyModel.fromJson(
        data['reply'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<void> deleteReply(String replyId) async {
    try {
      await _dio.delete('/resonance-replies/$replyId');
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  ResonanceException _handle(DioException e) {
    final response = e.response;
    if (response == null) {
      return ResonanceException(
        'Cannot reach Syaahi. Check your connection.',
      );
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
    return ResonanceException(message, statusCode: response.statusCode);
  }
}