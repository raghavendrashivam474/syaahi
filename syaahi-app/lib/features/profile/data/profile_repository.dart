import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/author_profile.dart';
import '../../../shared/models/poem.dart';
import '../../poems/data/poems_repository.dart' show PoemFeedResult, PoemsException;

/// Repository for user/author profile operations.
///
/// Owns the `/users/*` API domain:
/// - Public author profiles
/// - Author poem listings (cursor-paginated)
///
/// Distinct from [PoemsRepository] which owns `/poems/*`
/// (CRUD, heart, reactions).
class ProfileRepository {
  final Dio _dio;

  ProfileRepository({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  /// Fetch a public author profile by username.
  ///
  /// Maps to `GET /api/v1/users/:username`.
  ///
  /// Throws [PoemsException] (reused for consistency) on failure.
  /// A 404 response indicates the author does not exist.
  Future<AuthorProfile> getUserProfile(String username) async {
    try {
      final response = await _dio.get('/users/$username');
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthorProfile.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  /// Fetch an author's published poems with cursor-based pagination.
  ///
  /// Maps to `GET /api/v1/users/:username/poems?cursor=...&limit=...`.
  ///
  /// Returns a [PoemFeedResult] containing the poem list and an
  /// optional [nextCursor] for subsequent pages.
  ///
  /// The backend enforces a max limit of 50.
  Future<PoemFeedResult> getAuthorPoems(
    String username, {
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/users/$username/poems',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );
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

  /// Search for authors by username or display name.
  ///
  /// Maps to GET /api/v1/users/search?q=...&limit=....
  Future<List<AuthorProfile>> searchAuthors(
    String query, {
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/users/search',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final list = data['users'] as List<dynamic>;
      return list.map((j) {
        final map = j as Map<String, dynamic>;
        return AuthorProfile(
          id: map['username'] as String,
          username: map['username'] as String,
          displayName: map['displayName'] as String,
          bio: map['bio'] as String?,
          avatarUrl: map['avatarUrl'] as String?,
          createdAt: DateTime.now(),
          poemCount: 0,
        );
      }).toList();
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  /// Distinguish 404 (author not found) from network/server errors.
  PoemsException _handle(DioException e) {
    final response = e.response;
    if (response == null) {
      return PoemsException('Cannot reach Syaahi. Check your connection.');
    }
    if (response.statusCode == 404) {
      return PoemsException('Author not found', statusCode: 404);
    }
    final data = response.data;
    String message = 'Something went wrong';
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) {
        message = data['message'] as String;
      }
    }
    return PoemsException(message, statusCode: response.statusCode);
  }
}
