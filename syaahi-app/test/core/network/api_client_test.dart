import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syaahi_app/core/network/api_client.dart';
import 'package:syaahi_app/core/storage/token_storage.dart';

// ── Fake TokenStorage ─────────────────────────────────────────────

class _FakeTokenStorage extends TokenStorage {
  final String? token;
  final bool shouldThrow;
  final bool shouldTimeout;

  _FakeTokenStorage({
    this.token,
    this.shouldThrow = false,
    this.shouldTimeout = false,
  });

  @override
  Future<String?> getToken() async {
    if (shouldTimeout) {
      // Simulate a hang longer than the 3-second interceptor timeout.
      await Future.delayed(const Duration(seconds: 10));
    }
    if (shouldThrow) {
      throw Exception('PlatformException: secure storage unavailable');
    }
    return token;
  }

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<void> clearToken() async {}
}

// ── Helper: build a client with a fake adapter ────────────────────

/// Creates an ApiClient whose Dio uses a fake adapter that records
/// the request headers and returns a canned 200 response.
ApiClient _buildClient(
  TokenStorage storage, {
  List<Map<String, dynamic>>? capturedHeaders,
}) {
  final client = ApiClient(tokenStorage: storage);
  final dio = client.dio;

  // Replace the default adapter with one that captures and responds.
  dio.httpClientAdapter = _FakeAdapter(capturedHeaders: capturedHeaders);
  return client;
}

class _FakeAdapter implements HttpClientAdapter {
  final List<Map<String, dynamic>>? capturedHeaders;

  _FakeAdapter({this.capturedHeaders});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedHeaders?.add(Map<String, dynamic>.from(options.headers));
    return ResponseBody.fromString('{"ok":true}', 200);
  }

  @override
  void close({bool force = false}) {}
}

// ── Tests ─────────────────────────────────────────────────────────

void main() {
  group('ApiClient interceptor — token retrieval', () {
    test('succeeds: Bearer header is attached', () async {
      final headers = <Map<String, dynamic>>[];
      final client = _buildClient(
        _FakeTokenStorage(token: 'jwt-abc-123'),
        capturedHeaders: headers,
      );

      await client.dio.get('/test');

      expect(headers, hasLength(1));
      expect(headers.first['Authorization'], 'Bearer jwt-abc-123');
    });

    test('returns null: request proceeds without Authorization', () async {
      final headers = <Map<String, dynamic>>[];
      final client = _buildClient(
        _FakeTokenStorage(token: null),
        capturedHeaders: headers,
      );

      await client.dio.get('/test');

      expect(headers, hasLength(1));
      expect(headers.first.containsKey('Authorization'), isFalse);
    });

    test('throws exception: request proceeds without Authorization', () async {
      final headers = <Map<String, dynamic>>[];
      final client = _buildClient(
        _FakeTokenStorage(shouldThrow: true),
        capturedHeaders: headers,
      );

      // Must NOT throw — the interceptor catches and continues.
      final response = await client.dio.get('/test');

      expect(response.statusCode, 200);
      expect(headers, hasLength(1));
      expect(headers.first.containsKey('Authorization'), isFalse);
    });

    test('times out: request proceeds without Authorization', () async {
      final headers = <Map<String, dynamic>>[];
      final client = _buildClient(
        _FakeTokenStorage(shouldTimeout: true),
        capturedHeaders: headers,
      );

      // The interceptor has a 3-second timeout. The fake hangs for 10s.
      // This test verifies the request completes in ~3s, not 10s.
      final stopwatch = Stopwatch()..start();
      final response = await client.dio.get('/test');
      stopwatch.stop();

      expect(response.statusCode, 200);
      expect(headers, hasLength(1));
      expect(headers.first.containsKey('Authorization'), isFalse);
      // Should complete well under the 10s hang time.
      expect(stopwatch.elapsed.inSeconds, lessThan(8));
    });

    test('empty string token: treated as no token', () async {
      final headers = <Map<String, dynamic>>[];
      final client = _buildClient(
        _FakeTokenStorage(token: ''),
        capturedHeaders: headers,
      );

      await client.dio.get('/test');

      expect(headers, hasLength(1));
      expect(headers.first.containsKey('Authorization'), isFalse);
    });

    test('request never remains pending after token failure', () async {
      final client = _buildClient(
        _FakeTokenStorage(shouldThrow: true),
      );

      // If the interceptor fails to call handler.next(), this will hang
      // until the Dio receiveTimeout (15s). We verify it completes quickly.
      final stopwatch = Stopwatch()..start();
      await client.dio.get('/test');
      stopwatch.stop();

      expect(stopwatch.elapsed.inSeconds, lessThan(5));
    });
  });
}