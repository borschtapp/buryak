import 'package:flutter/material.dart';

import '../../shared/layouts/content_frame.dart';
import '../../shared/models/recipe_filter.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';

/// Section header row for the saved recipes list, including count badge,
/// active filter reset button, and sort order dropdown.
class SavedRecipesHeader extends StatelessWidget {
  final RecipeFilter filter;
  final void Function(SortField sort, SortOrder order) onSortChanged;
  final VoidCallback onClearFilter;

  const SavedRecipesHeader({
    super.key,
    required this.filter,
    required this.onSortChanged,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = recipeSortOptions(context.l10n);
    final currentSort = sortOptions.firstWhere((o) => o.field == filter.sort && o.order == filter.order);

    return ContentFrame(
      maxWidth: UIConstants.defaultMaxWidth,
      padding: const EdgeInsets.fromLTRB(UIConstants.paddingMedium, 16, UIConstants.paddingMedium, 8),
      child: Row(
        children: [
          Text(
            context.l10n.savedTabRecipes,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (filter.activeCountExcludingSearch > 0) ...[
            const SizedBox(width: 8),
            Badge.count(
              count: filter.activeCountExcludingSearch,
            ),
          ],
          const Spacer(),
          if (!filter.isEmpty)
            TextButton.icon(
              onPressed: onClearFilter,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: const Icon(Icons.filter_alt_off, size: 16),
              label: Text(context.l10n.feedClearFilters),
            ),
          PopupMenuButton(
            tooltip: context.l10n.recipesFilterSortBy,
            initialValue: currentSort,
            onSelected: (option) => onSortChanged(option.field, option.order),
            itemBuilder: (context) => [
              for (final option in sortOptions) PopupMenuItem(value: option, child: Text(option.label)),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentSort.label,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
