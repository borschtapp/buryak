import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/recipe_filter.dart';
import '../../util/extensions.dart';
import '../../util/ui_constants.dart';
import 'recipe_filters.dart';

/// A search bar row with a debounced text field and a filter button.
///
/// The filter button opens [RecipeFilters] via:
/// - Bottom sheet on mobile (Material 3)
/// - Full-page navigation on desktop
///
/// Text changes are debounced by 400ms.
class RecipeSearchBar extends HookWidget {
  final RecipeFilter filter;
  final ValueChanged<RecipeFilter> onChanged;

  /// When false, the filter screen will not show taxonomy sections (Cuisine, Diet, Category).
  final bool showTaxonomyFilters;

  /// Scope passed to the server when loading filter options (e.g. 'feeds', 'saved').
  final String? scope;

  /// Called with true when filters are opened, false when closed.
  /// Useful for hiding UI elements like FAB behind the filter sheet.
  final ValueChanged<bool>? onFiltersOpenChanged;

  const RecipeSearchBar({
    super.key,
    required this.filter,
    required this.onChanged,
    this.showTaxonomyFilters = true,
    this.scope,
    this.onFiltersOpenChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: filter.q ?? '');
    final queryText = useState(filter.q ?? '');
    final debouncedQuery = useDebounced(queryText.value, const Duration(milliseconds: 400));

    // Sync controller if filter is cleared externally (e.g. "Clear filters")
    useEffect(() {
      final newText = filter.q ?? '';
      if (controller.text != newText) {
        controller.text = newText;
        controller.selection = TextSelection.collapsed(offset: newText.length);
        queryText.value = newText;
      }
      return null;
    }, [filter.q]);

    useEffect(() {
      if (debouncedQuery == null) return null;
      final trimmed = debouncedQuery.trim();
      final currentQ = filter.q ?? '';
      if (trimmed != currentQ) {
        onChanged(filter.copyWith(q: trimmed.isEmpty ? null : trimmed));
      }
      return null;
    }, [debouncedQuery]);

    void onTextChanged(String value) {
      queryText.value = value;
    }

    Future<void> openFilters() async {
      final ctx = context;
      onFiltersOpenChanged?.call(true);
      try {
        late RecipeFilter? result;
        if (ctx.isMobile) {
          result = await showModalBottomSheet<RecipeFilter>(
            context: ctx,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => RecipeFilters(
              initialFilter: filter,
              showTaxonomyFilters: showTaxonomyFilters,
              scope: scope,
            ),
          );
        } else {
          result = await showGeneralDialog<RecipeFilter>(
            context: ctx,
            barrierDismissible: true,
            barrierLabel: ctx.l10n.dismissFilters,
            barrierColor: Colors.black54,
            pageBuilder: (ctx, animation, dismissAnimation) {
              return const SizedBox.shrink();
            },
            transitionBuilder: (ctx, animation, dismissAnimation, child) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const SizedBox.expand(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: RecipeFilters(
                        initialFilter: filter,
                        showTaxonomyFilters: showTaxonomyFilters,
                        scope: scope,
                        onFilterChanged: onChanged,
                      ),
                    ),
                  ),
                ],
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        }
        if (result != null) onChanged(result);
      } finally {
        onFiltersOpenChanged?.call(false);
      }
    }

    // Excludes `q` from the badge — the text field already shows it visually.
    final nonSearchActiveCount = filter.activeCountExcludingSearch;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onTextChanged,
            decoration: InputDecoration(
              hintText: context.l10n.recipesSearchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onChanged(filter.copyWith(q: null));
                      },
                    )
                  : null,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              filled: true,
            ),
          ),
        ),
        const SizedBox(width: UIConstants.paddingSmall),
        Badge.count(
          count: nonSearchActiveCount,
          isLabelVisible: nonSearchActiveCount > 0,
          child: IconButton.filledTonal(
            icon: const Icon(Icons.filter_alt),
            tooltip: context.l10n.recipesFilterTooltip,
            onPressed: openFilters,
          ),
        ),
      ],
    );
  }
}
