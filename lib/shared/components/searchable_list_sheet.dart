import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'error_state.dart';

import '../util/error_extensions.dart';
import '../util/extensions.dart';
import '../util/ui_constants.dart';

/// Bottom-sheet list whose results come from an async [search] (e.g. the
/// server), run debounced as the user types.
///
/// For a list that's already in memory use [FilterableListSheet].
class SearchableListSheet<T> extends HookWidget {
  const SearchableListSheet({
    super.key,
    required this.search,
    required this.itemBuilder,
    this.hintText,
    this.emptySearchText,
    this.emptyResultsText,
    this.minQueryLength = 0,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  final Future<List<T>> Function(String query) search;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String? hintText;
  final String? emptySearchText;
  final String? emptyResultsText;
  final int minQueryLength;
  final Duration debounceDuration;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final query = useValueListenable(searchController).text;
    final results = useState<List<T>>([]);
    final isLoading = useState(false);
    final error = useState<Object?>(null);
    final attempt = useState(0);
    final debouncedQuery = useDebounced(query, debounceDuration);

    useEffect(() {
      if (debouncedQuery == null) return null;

      if (debouncedQuery.length < minQueryLength) {
        results.value = [];
        isLoading.value = false;
        error.value = null;
        return null;
      }

      var cancelled = false;
      isLoading.value = true;
      () async {
        try {
          final res = await search(debouncedQuery);
          if (cancelled) return;
          results.value = res;
          error.value = null;
        } catch (e) {
          // Shown inline: an empty list would read as "no such item".
          if (!cancelled) error.value = e;
        } finally {
          if (!cancelled) isLoading.value = false;
        }
      }();

      return () => cancelled = true;
    }, [debouncedQuery, attempt.value]);

    return _SearchListLayout<T>(
      controller: searchController,
      hintText: hintText,
      // Keep current results on screen (and their scroll position) while a new
      // search loads; only show the spinner when there's nothing yet.
      loading: isLoading.value && results.value.isEmpty,
      refreshing: isLoading.value,
      items: results.value,
      emptyText: query.length < minQueryLength ? emptySearchText : emptyResultsText,
      itemBuilder: itemBuilder,
      error: isLoading.value ? null : error.value,
      onRetry: () => attempt.value++,
    );
  }
}

/// Bottom-sheet list over in-memory [items], narrowed as the user types by
/// [filter]. Changing [items] simply rebuilds with the current query.
class FilterableListSheet<T> extends HookWidget {
  const FilterableListSheet({
    super.key,
    required this.items,
    required this.filter,
    required this.itemBuilder,
    this.loading = false,
    this.error,
    this.onRetry,
    this.hintText,
    this.emptyResultsText,
  });

  final List<T> items;

  /// Whether [item] matches [query]. [query] is trimmed and lower-cased; it's
  /// never empty, since an empty query shows every item.
  final bool Function(T item, String query) filter;
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Shows a spinner instead of the list, e.g. while [items] first loads.
  final bool loading;

  /// Why [items] couldn't be loaded; shown instead of the list, with [onRetry].
  final Object? error;
  final VoidCallback? onRetry;
  final String? hintText;
  final String? emptyResultsText;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final query = useValueListenable(searchController).text.trim().toLowerCase();

    return _SearchListLayout<T>(
      controller: searchController,
      hintText: hintText,
      loading: loading,
      items: query.isEmpty ? items : items.where((item) => filter(item, query)).toList(),
      emptyText: emptyResultsText,
      itemBuilder: itemBuilder,
      error: error,
      onRetry: onRetry,
    );
  }
}

/// Search field over a result list, shared by [SearchableListSheet] and
/// [FilterableListSheet].
class _SearchListLayout<T> extends StatelessWidget {
  const _SearchListLayout({
    required this.controller,
    required this.loading,
    required this.items,
    required this.itemBuilder,
    this.refreshing = false,
    this.hintText,
    this.emptyText,
    this.error,
    this.onRetry,
  });

  final TextEditingController controller;

  /// Replaces the list with a spinner.
  final bool loading;

  /// Shows a thin progress bar over the current [items].
  final bool refreshing;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String? hintText;
  final String? emptyText;

  /// Shown instead of the list, e.g. when the search failed, with [onRetry].
  final Object? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.heightOf(context) * 0.75),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UIConstants.paddingContent,
              UIConstants.paddingMedium,
              UIConstants.paddingContent,
              UIConstants.paddingSmall,
            ),
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: controller.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: controller.clear) : null,
              ),
            ),
          ),
          Expanded(
            child: error != null
                ? SingleChildScrollView(
                    child: ErrorState(message: context.errorMessage(error), onRetry: onRetry),
                  )
                : loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                ? Center(
                    child: Text(
                      emptyText ?? '',
                      style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                    ),
                  )
                : Stack(
                    children: [
                      ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) => itemBuilder(context, items[index]),
                      ),
                      if (refreshing) const LinearProgressIndicator(),
                    ],
                  ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}
