import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/poem.dart';
import '../../domain/models/draft_poem.dart';
import '../mappers/draft_mapper.dart';

class RemoteDraftException implements Exception {
  final String message;
  final int? statusCode;
  RemoteDraftException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class RemoteDraftRepository {
  final Dio _dio;

  RemoteDraftRepository({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  Future<DraftPoem> createDraft(DraftPoem draft) async {
    try {
      final response = await _dio.post('/studio/drafts', data: DraftMapper.toRemoteJson(draft));
      final json = response.data['data']['draft'] as Map<String, dynamic>;
      return DraftMapper.fromRemoteJson(json, draft.ownerId);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<List<DraftPoem>> listDrafts(String ownerId) async {
    try {
      final response = await _dio.get('/studio/drafts');
      final list = response.data['data']['drafts'] as List<dynamic>;
      return list
          .map((j) => DraftMapper.fromRemoteJson(j as Map<String, dynamic>, ownerId))
          .toList();
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<DraftPoem> updateDraft(DraftPoem draft) async {
    try {
      final response = await _dio.patch('/studio/drafts/${draft.id}', data: DraftMapper.toRemoteJson(draft));
      final json = response.data['data']['draft'] as Map<String, dynamic>;
      return DraftMapper.fromRemoteJson(json, draft.ownerId);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<void> deleteDraft(String id) async {
    try {
      await _dio.delete('/studio/drafts/$id');
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  Future<Poem> publishDraft(String id) async {
    try {
      final response = await _dio.post('/studio/drafts/$id/publish');
      final json = response.data['data']['poem'] as Map<String, dynamic>;
      return Poem.fromJson(json);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  RemoteDraftException _handle(DioException e) {
    final response = e.response;
    if (response == null) {
      return RemoteDraftException('Cannot reach Syaahi. Offline mode active.');
    }
    final data = response.data;
    String msg = 'Remote draft operation failed';
    if (data is Map<String, dynamic> && data['message'] is String) {
      msg = data['message'] as String;
    }
    return RemoteDraftException(msg, statusCode: response.statusCode);
  }
}
