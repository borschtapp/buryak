import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/paginated_list.dart';

/// Adds offset-based infinite-scroll capability to any [AsyncNotifier] whose
/// state is a [List].
///
/// Usage:
/// ```dart
/// class MyNotifier extends _$MyNotifier with PagedNotifierMixin<Recipe> {
///   @override
///   Future<List<Recipe>> build() async {
///     resetPagination();
///     final result = await _fetch(0, limit);
///     return result.data;
///   }
///
///   Future<void> loadMore() => loadNextPage(_fetch);
///
///   Future<PaginatedList<Recipe>> _fetch(int offset, int limit) =>
///       ref.read(recipeRepositoryProvider).findAll(offset: offset, limit: limit);
/// }
/// ```
mixin PagedNotifierMixin<Item> {
  // Satisfied by $AsyncNotifier<List<Item>> in the mixed-in class hierarchy.
  AsyncValue<List<Item>> get state;

  set state(AsyncValue<List<Item>> newState);

  bool _initialized = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  /// Number of items per page. Override to change per-notifier.
  int get limit => 20;

  /// Optional callback to transform items after fetch (e.g., sorting).
  /// Override to customize item ordering.
  List<Item> Function(List<Item>)? get sortItems => null;

  /// Whether more pages are available.
  bool get hasMore => _hasMore;

  /// Whether a page fetch is currently in progress.
  bool get isLoadingMore => _isLoadingMore;

  /// Resets pagination state. MUST be called at the start of [build]
  /// to ensure consistent state across provider rebuilds.
  void resetPagination() {
    _initialized = true;
    _hasMore = true;
    _isLoadingMore = false;
  }

  /// Fetches the next page using [fetch] and appends results to [state].
  /// [fetch] receives the next offset and page size.
  /// Marks [hasMore] based on the total items count in the response metadata.
  ///
  /// If [sortItems] is set, sorting is applied **after** combining pages.
  Future<void> loadNextPage(Future<PaginatedList<Item>> Function(int offset, int limit) fetch) async {
    assert(_initialized, 'loadNextPage called before resetPagination() ran in build()');
    if (!_hasMore || _isLoadingMore) return;
    final current = state.value;
    if (current == null) return;

    _isLoadingMore = true;
    try {
      final result = await fetch(current.length, limit);
      final next = result.data;

      _hasMore = (result.meta.offset + next.length) < result.meta.total;
      var combined = [...current, ...next];

      // Apply sorting if provided
      final sortFn = sortItems;
      if (sortFn != null) {
        combined = sortFn(combined);
      }

      state = AsyncData(combined);
    } finally {
      _isLoadingMore = false;
    }
  }
}
