import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notifications_repository.dart';

// ── Repository ───────────────────────────────────────────────────────

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepository();
});

// ── Unread Count (survives inbox disposal — shown on feed bell) ─────

class UnreadCountNotifier extends StateNotifier<int?> {
  final NotificationsRepository _repository;

  UnreadCountNotifier(this._repository) : super(null);

  Future<void> refresh() async {
    try {
      state = await _repository.getUnreadCount();
    } catch (_) {
      // Keep existing count on failure — never show 0 falsely.
    }
  }

  void decrement() {
    if (state != null && state! > 0) state = state! - 1;
  }

  void zero() {
    state = 0;
  }
}

final unreadCountProvider =
    StateNotifierProvider<UnreadCountNotifier, int?>((ref) {
  return UnreadCountNotifier(ref.watch(notificationsRepositoryProvider));
});

// ── Inbox State ──────────────────────────────────────────────────────

class InboxState {
  final List<AppNotification> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final String? error;
  final bool isMarkingAllRead;

  const InboxState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.nextCursor,
    this.error,
    this.isMarkingAllRead = false,
  });

  InboxState copyWith({
    List<AppNotification>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? nextCursor,
    String? error,
    bool clearError = false,
    bool? isMarkingAllRead,
  }) {
    return InboxState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      error: clearError ? null : (error ?? this.error),
      isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
    );
  }
}

// ── Inbox Notifier ───────────────────────────────────────────────────

class InboxNotifier extends StateNotifier<InboxState> {
  final NotificationsRepository _repository;
  final Ref _ref;

  InboxNotifier(this._repository, this._ref) : super(const InboxState()) {
    load();
  }

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.listNotifications(limit: 20);
      state = state.copyWith(
        items: result.items,
        nextCursor: result.nextCursor,
        hasMore: result.nextCursor != null,
        isLoading: false,
      );
    } on NotificationsException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.nextCursor == null) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _repository.listNotifications(
        cursor: state.nextCursor,
        limit: 20,
      );
      // Deduplicate across page boundaries
      final existingIds = state.items.map((n) => n.id).toSet();
      final fresh = result.items
          .where((n) => !existingIds.contains(n.id))
          .toList();
      state = state.copyWith(
        items: [...state.items, ...fresh],
        nextCursor: result.nextCursor,
        hasMore: result.nextCursor != null,
        isLoadingMore: false,
      );
    } on NotificationsException catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.message);
    }
  }

  Future<void> refresh() async {
    state = const InboxState();
    await load();
    _ref.read(unreadCountProvider.notifier).refresh();
  }

  /// Server-first: update local state only after the API confirms.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      state = state.copyWith(
        items: state.items.map((n) {
          if (n.id == notificationId && !n.isRead) {
            return AppNotification(
              id: n.id,
              type: n.type,
              poemId: n.poemId,
              readAt: DateTime.now(),
              createdAt: n.createdAt,
              poem: n.poem,
            );
          }
          return n;
        }).toList(),
      );
      _ref.read(unreadCountProvider.notifier).decrement();
    } on NotificationsException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  /// Server-first: clear all read states only after the API confirms.
  Future<void> markAllAsRead() async {
    if (state.isMarkingAllRead) return;
    state = state.copyWith(isMarkingAllRead: true);
    try {
      await _repository.markAllAsRead();
      state = state.copyWith(
        isMarkingAllRead: false,
        clearError: true,
        items: state.items.map((n) {
          if (!n.isRead) {
            return AppNotification(
              id: n.id,
              type: n.type,
              poemId: n.poemId,
              readAt: DateTime.now(),
              createdAt: n.createdAt,
              poem: n.poem,
            );
          }
          return n;
        }).toList(),
      );
      _ref.read(unreadCountProvider.notifier).zero();
    } on NotificationsException catch (e) {
      state = state.copyWith(isMarkingAllRead: false, error: e.message);
    }
  }
}

final inboxProvider =
    StateNotifierProvider.autoDispose<InboxNotifier, InboxState>((ref) {
  return InboxNotifier(ref.watch(notificationsRepositoryProvider), ref);
});
