import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../util/extensions.dart';
import '../util/ui_constants.dart';

class SearchableListSheet<T> extends HookWidget {
  const SearchableListSheet({
    super.key,
    this.initialLoading = false,
    required this.search,
    required this.itemBuilder,
    this.hintText,
    this.emptySearchText,
    this.emptyResultsText,
    this.minQueryLength = 0,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  final bool initialLoading;
  final FutureOr<List<T>> Function(String query) search;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String? hintText;
  final String? emptySearchText;
  final String? emptyResultsText;
  final int minQueryLength;
  final Duration debounceDuration;

  @override
  Widget build(BuildContext context) {
    final query = useState('');
    final searchController = useTextEditingController();
    final results = useState<List<T>>([]);
    final isLoading = useState(false);
    final debouncedQuery = useDebounced(query.value, debounceDuration);

    useEffect(() {
      if (initialLoading) return null;
      if (debouncedQuery == null) return null;

      if (debouncedQuery.length < minQueryLength) {
        results.value = [];
        isLoading.value = false;
        return null;
      }

      var cancelled = false;

      void performSearch() async {
        if (cancelled) return;
        isLoading.value = true;
        try {
          final res = await search(debouncedQuery);
          if (!cancelled) {
            results.value = res;
          }
        } catch (_) {
          if (!cancelled) results.value = [];
        } finally {
          if (!cancelled) isLoading.value = false;
        }
      }

      performSearch();

      return () {
        cancelled = true;
      };
    }, [debouncedQuery, initialLoading]); // Re-run if initialLoading changes

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
              controller: searchController,
              autofocus: true,
              onChanged: (v) => query.value = v,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: query.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          query.value = '';
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: initialLoading || isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : results.value.isEmpty
                ? Center(
                    child: Text(
                      query.value.length < minQueryLength ? (emptySearchText ?? '') : (emptyResultsText ?? ''),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: results.value.length,
                    itemBuilder: (context, index) {
                      final item = results.value[index];
                      final child = itemBuilder(context, item);
                      return child;
                    },
                  ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}
