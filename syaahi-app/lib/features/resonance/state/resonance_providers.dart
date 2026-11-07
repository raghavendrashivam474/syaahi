import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/resonance_repository.dart';

final resonanceRepositoryProvider = Provider<ResonanceRepository>((ref) {
  return ResonanceRepository();
});

class ResonanceState {
  final List<ResonanceResponseModel> responses;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? actionError;

  const ResonanceState({
    this.responses = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.actionError,
  });

  ResonanceState copyWith({
    List<ResonanceResponseModel>? responses,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    String? actionError,
    bool clearActionError = false,
  }) {
    return ResonanceState(
      responses: responses ?? this.responses,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }
}

class ResonanceNotifier extends StateNotifier<ResonanceState> {
  final ResonanceRepository _repository;
  final String poemId;

  ResonanceNotifier(this._repository, this.poemId)
      : super(const ResonanceState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.listResponses(poemId);
      state = state.copyWith(
        responses: result.responses,
        isLoading: false,
      );
    } on ResonanceException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<bool> submitResponse(String content) async {
    if (state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, clearActionError: true);
    try {
      final newResp = await _repository.createResponse(poemId, content);
      state = state.copyWith(
        responses: [...state.responses, newResp],
        isSubmitting: false,
      );
      return true;
    } on ResonanceException catch (e) {
      state = state.copyWith(isSubmitting: false, actionError: e.message);
      return false;
    }
  }

  Future<bool> editResponse(String responseId, String content) async {
    try {
      final updated = await _repository.updateResponse(responseId, content);
      state = state.copyWith(
        responses: state.responses.map((r) {
          return r.id == responseId ? updated : r;
        }).toList(),
      );
      return true;
    } on ResonanceException catch (e) {
      state = state.copyWith(actionError: e.message);
      return false;
    }
  }

  Future<bool> deleteResponse(String responseId) async {
    try {
      await _repository.deleteResponse(responseId);
      state = state.copyWith(
        responses: state.responses.where((r) => r.id != responseId).toList(),
      );
      return true;
    } on ResonanceException catch (e) {
      state = state.copyWith(actionError: e.message);
      return false;
    }
  }

  Future<bool> submitReply(String responseId, String content) async {
    try {
      final reply = await _repository.createReply(responseId, content);
      state = state.copyWith(
        responses: state.responses.map((r) {
          if (r.id != responseId) return r;
          return ResonanceResponseModel(
            id: r.id,
            poemId: r.poemId,
            userId: r.userId,
            content: r.content,
            user: r.user,
            reply: reply,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          );
        }).toList(),
      );
      return true;
    } on ResonanceException catch (e) {
      state = state.copyWith(actionError: e.message);
      return false;
    }
  }

  Future<bool> editReply(
    String responseId,
    String replyId,
    String content,
  ) async {
    try {
      final updatedReply = await _repository.updateReply(replyId, content);
      state = state.copyWith(
        responses: state.responses.map((r) {
          if (r.id != responseId) return r;
          return ResonanceResponseModel(
            id: r.id,
            poemId: r.poemId,
            userId: r.userId,
            content: r.content,
            user: r.user,
            reply: updatedReply,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          );
        }).toList(),
      );
      return true;
    } on ResonanceException catch (e) {
      state = state.copyWith(actionError: e.message);
      return false;
    }
  }

  Future<bool> deleteReply(String responseId, String replyId) async {
    try {
      await _repository.deleteReply(replyId);
      state = state.copyWith(
        responses: state.responses.map((r) {
          if (r.id != responseId) return r;
          return ResonanceResponseModel(
            id: r.id,
            poemId: r.poemId,
            userId: r.userId,
            content: r.content,
            user: r.user,
            reply: null,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          );
        }).toList(),
      );
      return true;
    } on ResonanceException catch (e) {
      state = state.copyWith(actionError: e.message);
      return false;
    }
  }
}

final resonanceProvider = StateNotifierProvider.family
    .autoDispose<ResonanceNotifier, ResonanceState, String>((ref, poemId) {
  final repo = ref.watch(resonanceRepositoryProvider);
  return ResonanceNotifier(repo, poemId);
});