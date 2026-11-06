import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/author_profile.dart';
import '../../../shared/models/poem.dart';
import '../../poems/data/poems_repository.dart' show PoemsException;
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final authorProfileProvider =
    FutureProvider.autoDispose.family<AuthorProfile, String>((ref, username) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getUserProfile(username);
});

class AuthorPoemsState {
  final List<Poem> poems;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final String? error;

  const AuthorPoemsState({
    this.poems = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.nextCursor,
    this.error,
  });

  AuthorPoemsState copyWith({
    List<Poem>? poems,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? nextCursor,
    String? error,
    bool clearError = false,
  }) {
    return AuthorPoemsState(
      poems: poems ?? this.poems,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthorPoemsNotifier extends StateNotifier<AuthorPoemsState> {
  final ProfileRepository _repository;
  final String _username;

  AuthorPoemsNotifier(this._repository, this._username)
      : super(const AuthorPoemsState()) {
    load();
  }

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.getAuthorPoems(_username, limit: 20);
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
      final result = await _repository.getAuthorPoems(
        _username,
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
    state = const AuthorPoemsState();
    await load();
  }
}

final authorPoemsProvider = StateNotifierProvider.autoDispose
    .family<AuthorPoemsNotifier, AuthorPoemsState, String>((ref, username) {
  final repo = ref.watch(profileRepositoryProvider);
  return AuthorPoemsNotifier(repo, username);
});
