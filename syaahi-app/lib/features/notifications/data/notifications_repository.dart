import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

// ── Exception ────────────────────────────────────────────────────────

class NotificationsException implements Exception {
  final String message;
  final int? statusCode;
  NotificationsException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

// ── Models ───────────────────────────────────────────────────────────

class NotificationPoem {
  final String id;
  final String? title;

  const NotificationPoem({required this.id, this.title});

  factory NotificationPoem.fromJson(Map<String, dynamic> json) {
    return NotificationPoem(
      id: json['id'] as String,
      title: json['title'] as String?,
    );
  }
}

/// Named `AppNotification` to avoid collision with Flutter's
/// `Notification` widget class from `package:flutter/widgets.dart`.
class AppNotification {
  final String id;
  final String type;
  final String poemId;
  final DateTime? readAt;
  final DateTime createdAt;
  final NotificationPoem poem;

  const AppNotification({
    required this.id,
    required this.type,
    required this.poemId,
    this.readAt,
    required this.createdAt,
    required this.poem,
  });

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      poemId: json['poemId'] as String,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      poem: NotificationPoem.fromJson(
        json['poem'] as Map<String, dynamic>,
      ),
    );
  }
}

class NotificationInboxResult {
  final List<AppNotification> items;
  final String? nextCursor;

  const NotificationInboxResult({required this.items, this.nextCursor});
}

// ── Repository ───────────────────────────────────────────────────────

class NotificationsRepository {
  final Dio _dio;

  NotificationsRepository({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  /// Fetch a page of notifications.
  /// Mirrors [PoemsRepository.listPoems] pagination pattern.
  Future<NotificationInboxResult> listNotifications({
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final list = data['items'] as List<dynamic>;
      final items = list
          .map((j) => AppNotification.fromJson(j as Map<String, dynamic>))
          .toList();
      final nextCursor = data['nextCursor'] as String?;
      return NotificationInboxResult(items: items, nextCursor: nextCursor);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  /// Fetch the current unread notification count.
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      final data = response.data['data'] as Map<String, dynamic>;
      return data['unreadCount'] as int;
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  /// Mark a single notification as read. Idempotent on the backend.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.patch('/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  /// Mark all unread notifications as read.
  /// Returns the number of records updated by the server.
  Future<int> markAllAsRead() async {
    try {
      final response = await _dio.patch('/notifications/read-all');
      final data = response.data['data'] as Map<String, dynamic>;
      return data['markedCount'] as int;
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  // ── Error handling (mirrors PoemsRepository._handle) ──

  NotificationsException _handle(DioException e) {
    final response = e.response;
    if (response == null) {
      return NotificationsException(
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
    return NotificationsException(message, statusCode: response.statusCode);
  }
}
