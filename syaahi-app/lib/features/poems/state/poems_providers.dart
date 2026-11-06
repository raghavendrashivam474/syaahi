import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/poem.dart';
import '../data/poems_repository.dart';

final poemsRepositoryProvider = Provider<PoemsRepository>((ref) {
  return PoemsRepository();
});

// ---------------------------------------------
// Heart Status (UX-01)
// ---------------------------------------------

enum HeartStatus {
  unknown,
  loading,
  hearted,
  notHearted,
  updating,
  failed;

  bool get isHearted => this == hearted;
  bool get isLoading => this == loading || this == updating;
  bool get isInteractive => this == hearted || this == notHearted;
}

// ---------------------------------------------
// Feed State
// ---------------------------------------------

class FeedState {
  final List<Poem> poems;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final String? error;
  final FeedFilters filters;
  final Map<String, HeartStatus> heartStates; // UX-01

  const FeedState({
    this.poems = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.nextCursor,
    this.error,
    this.filters = const FeedFilters(),
    this.heartStates = const {}, // UX-01
  });

  FeedState copyWith({
    List<Poem>? poems,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? nextCursor,
    String? error,
    bool clearError = false,
    FeedFilters? filters,
    Map<String, HeartStatus>? heartStates, // UX-01
  }) {
    return FeedState(
      poems: poems ?? this.poems,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      error: clearError ? null : (error ?? this.error),
      filters: filters ?? this.filters,
      heartStates: heartStates ?? this.heartStates, // UX-01
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final PoemsRepository _repository;

  FeedNotifier(this._repository) : super(const FeedState()) {
    load();
  }

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.listPoems(
        limit: 10,
        filters: state.filters,
      );
      state = state.copyWith(
        poems: result.poems,
        nextCursor: result.nextCursor,
        hasMore: result.nextCursor != null,
        isLoading: false,
      );
    } on PoemsException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.nextCursor == null) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _repository.listPoems(
        cursor: state.nextCursor,
        limit: 10,
        filters: state.filters,
      );
      state = state.copyWith(
        poems: [...state.poems, ...result.poems],
        nextCursor: result.nextCursor,
        hasMore: result.nextCursor != null,
        isLoadingMore: false,
      );
    } on PoemsException catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.message);
    }
  }

  Future<void> refresh() async {
    // heartStates resets to {} via default constructor — UX-01
    state = FeedState(filters: state.filters);
    await load();
  }

  Future<void> setFilters(FeedFilters filters) async {
    state = FeedState(filters: filters);
    await load();
  }

  Future<void> clearFilters() async {
    state = const FeedState();
    await load();
  }

  // ── UX-01: Heart hydration & toggle ──────────────────────────────

  /// Hydrate the heart status for a single poem.
  /// Only fetches if the status is currently [HeartStatus.unknown].
  Future<void> hydrateHeart(String poemId) async {
    final current = state.heartStates[poemId] ?? HeartStatus.unknown;
    if (current != HeartStatus.unknown) return;

    _updateHeartStatus(poemId, HeartStatus.loading);

    try {
      final hearted = await _repository.getHeartStatus(poemId);
      _updateHeartStatus(
        poemId,
        hearted ? HeartStatus.hearted : HeartStatus.notHearted,
      );
    } catch (_) {
      // Default to notHearted so the user can still interact.
      // A subsequent toggle will re-fetch the true state.
      _updateHeartStatus(poemId, HeartStatus.notHearted);
    }
  }

  /// Toggle heart status for a poem directly from the feed.
  Future<bool> toggleHeart(String poemId) async {
    final current = state.heartStates[poemId] ?? HeartStatus.unknown;

    // If state is unknown, hydrate first then toggle
    if (current == HeartStatus.unknown || current == HeartStatus.loading) {
      await hydrateHeart(poemId);
      final hydrated = state.heartStates[poemId] ?? HeartStatus.notHearted;
      if (hydrated.isLoading) return false; // still in flight
      return _performToggle(poemId, hydrated);
    }

    // Prevent duplicate taps while updating
    if (current == HeartStatus.updating) return false;

    return _performToggle(poemId, current);
  }

  Future<bool> _performToggle(String poemId, HeartStatus current) async {
    final wasHearted = current == HeartStatus.hearted;
    final previousStatus = current;

    // Optimistic update
    _updateHeartStatus(poemId, HeartStatus.updating);

    try {
      if (wasHearted) {
        await _repository.removeFromHeart(poemId);
      } else {
        await _repository.commitToHeart(poemId);
      }
      _updateHeartStatus(
        poemId,
        wasHearted ? HeartStatus.notHearted : HeartStatus.hearted,
      );
      return true;
    } catch (_) {
      // Rollback to previous authoritative state
      _updateHeartStatus(poemId, previousStatus);
      return false;
    }
  }

  void _updateHeartStatus(String poemId, HeartStatus status) {
    state = state.copyWith(
      heartStates: {...state.heartStates, poemId: status},
    );
  }

  /// Invalidate a single poem's cached heart state.
  /// Called when the reader changes heart status for a poem,
  /// so the feed re-hydrates on next display.
  void invalidateHeart(String poemId) {
    final updated = Map<String, HeartStatus>.from(state.heartStates);
    updated.remove(poemId);
    state = state.copyWith(heartStates: updated);
  }
}

final feedProvider =
    StateNotifierProvider.autoDispose<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(ref.watch(poemsRepositoryProvider));
});

// ---------------------------------------------
// Single poem
// ---------------------------------------------

final poemByIdProvider =
    FutureProvider.autoDispose.family<Poem, String>((ref, id) async {
  final repo = ref.watch(poemsRepositoryProvider);
  return repo.getPoem(id);
});

// ---------------------------------------------
// Writer
// ---------------------------------------------

class WriterState {
  final bool isPublishing;
  final String? error;
  const WriterState({this.isPublishing = false, this.error});
  WriterState copyWith({
    bool? isPublishing,
    String? error,
    bool clearError = false,
  }) =>
      WriterState(
        isPublishing: isPublishing ?? this.isPublishing,
        error: clearError ? null : (error ?? this.error),
      );
}

class WriterNotifier extends StateNotifier<WriterState> {
  final PoemsRepository _repository;
  final Ref _ref;
  WriterNotifier(this._repository, this._ref) : super(const WriterState());
  Future<Poem?> publish({
    String? title,
    required String content,
    required PoemLanguage language,
    PoemEmotion? emotion,
    String? theme,
  }) async {
    state = state.copyWith(isPublishing: true, clearError: true);
    try {
      final poem = await _repository.createPoem(
        title: title,
        content: content,
        language: language,
        emotion: emotion,
        theme: theme,
      );
      state = state.copyWith(isPublishing: false);
      _ref.read(feedProvider.notifier).refresh();
      return poem;
    } on PoemsException catch (e) {
      state = state.copyWith(isPublishing: false, error: e.message);
      return null;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final writerProvider =
    StateNotifierProvider<WriterNotifier, WriterState>((ref) {
  return WriterNotifier(ref.watch(poemsRepositoryProvider), ref);
});

// ---------------------------------------------
// Heart
// ---------------------------------------------

class HeartState {
  final List<Poem> poems;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final String? error;
  const HeartState({
    this.poems = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.nextCursor,
    this.error,
  });
  HeartState copyWith({
    List<Poem>? poems,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? nextCursor,
    String? error,
    bool clearError = false,
  }) {
    return HeartState(
      poems: poems ?? this.poems,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HeartNotifier extends StateNotifier<HeartState> {
  final PoemsRepository _repository;
  HeartNotifier(this._repository) : super(const HeartState()) {
    load();
  }
  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.getMyHeart(limit: 20);
      state = state.copyWith(
        poems: result.poems,
        nextCursor: result.nextCursor,
        hasMore: result.nextCursor != null,
        isLoading: false,
      );
    } on PoemsException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.nextCursor == null) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _repository.getMyHeart(
        cursor: state.nextCursor,
        limit: 20,
      );
      state = state.copyWith(
        poems: [...state.poems, ...result.poems],
        nextCursor: result.nextCursor,
        hasMore: result.nextCursor != null,
        isLoadingMore: false,
      );
    } on PoemsException catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.message);
    }
  }

  Future<void> refresh() async {
    state = const HeartState();
    await load();
  }
}

final heartProvider =
    StateNotifierProvider.autoDispose<HeartNotifier, HeartState>((ref) {
  return HeartNotifier(ref.watch(poemsRepositoryProvider));
});

final userPoemsProvider =
    FutureProvider.autoDispose.family<List<Poem>, String>((ref, username) async {
  final repo = ref.watch(poemsRepositoryProvider);
  return repo.getUserPoems(username, limit: 50);
});
