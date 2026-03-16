import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'models/paginated_list.dart';

/// Adds offset-based infinite-scroll capability to any [AsyncNotifier] whose
/// state is a [List].
///
/// Usage:
/// ```dart
/// class MyNotifier extends _$MyNotifier with PagedNotifierMixin<Recipe> {
///   @override
///   Future<List<Recipe>> build() async {
///     resetPagination();
///     final result = await _fetch(0, pageSize);
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

  /// Number of items per page. Override to change per-notifier.
  int get pageSize => 20;

  /// Whether more pages are available.
  bool get hasMore => _hasMore;

  /// Resets pagination state. MUST be called at the start of [build]
  /// to ensure consistent state across provider rebuilds.
  void resetPagination() {
    _initialized = true;
    _hasMore = true;
  }

  /// Fetches the next page using [fetch] and appends results to [state].
  /// [fetch] receives the next offset and page size.
  /// Marks [hasMore] based on the total items count in the response metadata.
  Future<void> loadNextPage(Future<PaginatedList<Item>> Function(int offset, int limit) fetch) async {
    assert(_initialized, 'loadNextPage called before resetPagination() ran in build()');
    if (!_hasMore) return;
    final current = state.asData?.value;
    if (current == null) return;

    final result = await fetch(current.length, pageSize);
    final next = result.data;
    
    _hasMore = (result.meta.offset + next.length) < result.meta.total;
    state = AsyncData([...current, ...next]);
  }
}
