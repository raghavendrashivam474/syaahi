import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/author_profile.dart';
import '../../poems/data/poems_repository.dart' show PoemsException;
import '../../profile/data/profile_repository.dart';
import '../../profile/state/profile_providers.dart';

/// Possible states of the discovery search flow.
enum DiscoveryStatus { initial, searching, results, empty, error }

/// Immutable state for the author discovery screen.
class DiscoveryState {
  final String query;
  final List<AuthorProfile> results;
  final DiscoveryStatus status;
  final String? errorMessage;

  const DiscoveryState({
    this.query = '',
    this.results = const [],
    this.status = DiscoveryStatus.initial,
    this.errorMessage,
  });

  DiscoveryState copyWith({
    String? query,
    List<AuthorProfile>? results,
    DiscoveryStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DiscoveryState(
      query: query ?? this.query,
      results: results ?? this.results,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Manages author search with debouncing and stale-response protection.
///
/// Follows the same StateNotifier pattern as [AuthorPoemsNotifier].
class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  final ProfileRepository _repository;
  Timer? _debounceTimer;
  int _requestVersion = 0;

  DiscoveryNotifier(this._repository) : super(const DiscoveryState());

  /// Called on every keystroke in the search field.
  ///
  /// Debounces by 500ms. Ignores queries shorter than 2 characters.
  void onQueryChanged(String query) {
    _debounceTimer?.cancel();

    final trimmed = query.trim();
    state = state.copyWith(query: query, clearError: true);

    if (trimmed.length < 2) {
      state = state.copyWith(
        results: const [],
        status: DiscoveryStatus.initial,
      );
      return;
    }

    state = state.copyWith(status: DiscoveryStatus.searching);

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _executeSearch(trimmed);
    });
  }

  Future<void> _executeSearch(String query) async {
    final version = ++_requestVersion;

    try {
      final results = await _repository.searchAuthors(query);

      // Discard stale responses from earlier queries.
      if (version != _requestVersion) return;

      if (results.isEmpty) {
        state = state.copyWith(
          results: const [],
          status: DiscoveryStatus.empty,
        );
      } else {
        state = state.copyWith(
          results: results,
          status: DiscoveryStatus.results,
        );
      }
    } on PoemsException catch (e) {
      if (version != _requestVersion) return;
      state = state.copyWith(
        status: DiscoveryStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      if (version != _requestVersion) return;
      state = state.copyWith(
        status: DiscoveryStatus.error,
        errorMessage: 'Something went wrong',
      );
    }
  }

  /// Clears the search and returns to the initial state.
  void clear() {
    _debounceTimer?.cancel();
    _requestVersion++;
    state = const DiscoveryState();
  }

  /// Retries the last failed search.
  void retry() {
    final trimmed = state.query.trim();
    if (trimmed.length >= 2) {
      state = state.copyWith(
        status: DiscoveryStatus.searching,
        clearError: true,
      );
      _executeSearch(trimmed);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Auto-disposing provider scoped to the discovery screen.
final discoveryProvider =
    StateNotifierProvider.autoDispose<DiscoveryNotifier, DiscoveryState>(
  (ref) {
    final repo = ref.watch(profileRepositoryProvider);
    return DiscoveryNotifier(repo);
  },
);
