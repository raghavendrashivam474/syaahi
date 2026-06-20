import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/poem.dart';
import '../data/poems_repository.dart';

final poemsRepositoryProvider = Provider<PoemsRepository>((ref) {
  return PoemsRepository();
});

// Feed: list of poems
final feedProvider = FutureProvider.autoDispose<List<Poem>>((ref) async {
  final repo = ref.watch(poemsRepositoryProvider);
  return repo.listPoems();
});

// Single poem by id
final poemByIdProvider =
    FutureProvider.autoDispose.family<Poem, String>((ref, id) async {
  final repo = ref.watch(poemsRepositoryProvider);
  return repo.getPoem(id);
});

// Writer state
class WriterState {
  final bool isPublishing;
  final String? error;
  const WriterState({this.isPublishing = false, this.error});

  WriterState copyWith({bool? isPublishing, String? error, bool clearError = false}) =>
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
      // Refresh the feed so the new poem appears
      _ref.invalidate(feedProvider);
      return poem;
    } on PoemsException catch (e) {
      state = state.copyWith(isPublishing: false, error: e.message);
      return null;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final writerProvider = StateNotifierProvider<WriterNotifier, WriterState>((ref) {
  return WriterNotifier(ref.watch(poemsRepositoryProvider), ref);
});