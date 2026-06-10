import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/equipment.dart';
import '../../models/publisher.dart';
import '../../models/recipe_filter.dart';
import '../../models/taxonomy.dart';
import '../../repositories/equipment_repository.dart';
import '../../repositories/publisher_repository.dart';
import '../../repositories/taxonomy_repository.dart';
import '../../util/extensions.dart';
import '../../util/ui_constants.dart';
import '../loading_with_message.dart';

part 'recipe_filters.g.dart';

@riverpod
Future<List<Taxonomy>> _taxonomiesByType(Ref ref, String type, String? scope) async {
  final result = await ref
      .watch(taxonomyRepositoryProvider)
      .findAll(
        type: type,
        scope: scope,
        preload: [TaxonomyPreload.total_recipes],
        sort: 'total_recipes',
        order: 'DESC',
        limit: 10,
      );
  return result.data;
}

@riverpod
Future<List<Publisher>> _topPublishers(Ref ref, String? scope) async {
  final result = await ref
      .watch(publisherRepositoryProvider)
      .findAll(
        scope: scope,
        preload: [PublisherPreload.total_recipes],
        sort: 'total_recipes',
        order: 'DESC',
        limit: 10,
      );
  return result.data;
}

@riverpod
Future<List<Equipment>> _equipment(Ref ref, String? scope) async {
  final result = await ref
      .watch(equipmentRepositoryProvider)
      .findAll(
        scope: scope,
        preload: [EquipmentPreload.total_recipes],
        sort: 'total_recipes',
        order: 'DESC',
        limit: 10,
      );
  return result.data;
}

class RecipeFilters extends HookConsumerWidget {
  final RecipeFilter initialFilter;
  final bool showTaxonomyFilters;
  final String? scope;

  /// Called when filter changes. On desktop, set this to apply changes live.
  /// On mobile, leave null to require explicit "Apply" tap.
  final ValueChanged<RecipeFilter>? onFilterChanged;

  const RecipeFilters({
    super.key,
    required this.initialFilter,
    this.showTaxonomyFilters = true,
    this.scope,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sortOptions = [
      (label: l10n.recipesFilterSortNewest, field: SortField.id, order: SortOrder.desc),
      (label: l10n.recipesFilterSortOldest, field: SortField.id, order: SortOrder.asc),
      (label: l10n.recipesFilterSortNameAZ, field: SortField.name, order: SortOrder.asc),
      (label: l10n.recipesFilterSortNameZA, field: SortField.name, order: SortOrder.desc),
    ];

    final filter = useState(initialFilter);

    void updateFilter(RecipeFilter Function(RecipeFilter) updater) {
      final newFilter = updater(filter.value);
      filter.value = newFilter;
      onFilterChanged?.call(newFilter);
    }

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.recipesFilterTitle),
        leading: context.isMobile
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: UIConstants.paddingMedium),
            child: TextButton(
              onPressed: () {
                filter.value = const RecipeFilter();
                onFilterChanged?.call(filter.value);
              },
              child: Text(context.l10n.recipesFilterClearAll),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingSmall),
        children: [
          _SectionHeader(l10n.recipesFilterSortBy),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingMedium,
              vertical: UIConstants.paddingSmall,
            ),
            child: Wrap(
              spacing: UIConstants.paddingSmall,
              runSpacing: UIConstants.paddingSmall,
              children: [
                for (final opt in sortOptions)
                  FilterChip(
                    label: Text(opt.label),
                    selected: filter.value.sort == opt.field && filter.value.order == opt.order,
                    onSelected: (_) => updateFilter((f) => f.copyWith(sort: opt.field, order: opt.order)),
                  ),
              ],
            ),
          ),
          _SectionHeader(l10n.recipesFilterCookTime),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingMedium,
              vertical: UIConstants.paddingSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filter.value.cookTimeMax == null
                      ? l10n.recipesFilterAnyTime
                      : l10n.recipesFilterUpToMinutes((filter.value.cookTimeMax! / 60).round()),
                  style: context.textTheme.bodySmall,
                ),
                const SizedBox(height: UIConstants.paddingSmall),
                Slider(
                  min: 0,
                  max: 3600,
                  divisions: 60,
                  value: filter.value.cookTimeMax?.toDouble() ?? 0,
                  onChanged: (value) => updateFilter(
                    (f) => f.copyWith(cookTimeMax: value == 0 ? null : value.toInt()),
                  ),
                ),
              ],
            ),
          ),
          if (showTaxonomyFilters) ...[
            _FilterSection<Taxonomy>(
              title: l10n.recipesFilterCuisine,
              provider: _taxonomiesByTypeProvider('cuisine', scope),
              itemMapper: (t) => (id: t.id, label: t.label ?? t.slug ?? t.id, count: t.totalRecipes),
              selectedIds: filter.value.taxonomyIds,
              onToggle: (id) => updateFilter((f) => f.copyWith(taxonomyIds: f.taxonomyIds.toggled(id))),
            ),
            _FilterSection<Taxonomy>(
              title: l10n.recipesFilterDiet,
              provider: _taxonomiesByTypeProvider('diet', scope),
              itemMapper: (t) => (id: t.id, label: t.label ?? t.slug ?? t.id, count: t.totalRecipes),
              selectedIds: filter.value.taxonomyIds,
              onToggle: (id) => updateFilter((f) => f.copyWith(taxonomyIds: f.taxonomyIds.toggled(id))),
            ),
            _FilterSection<Taxonomy>(
              title: l10n.recipesFilterCategory,
              provider: _taxonomiesByTypeProvider('category', scope),
              itemMapper: (t) => (id: t.id, label: t.label ?? t.slug ?? t.id, count: t.totalRecipes),
              selectedIds: filter.value.taxonomyIds,
              onToggle: (id) => updateFilter((f) => f.copyWith(taxonomyIds: f.taxonomyIds.toggled(id))),
            ),
            _FilterSection<Publisher>(
              title: l10n.recipesFilterPublisher,
              provider: _topPublishersProvider(scope),
              itemMapper: (p) => (id: p.id, label: p.name, count: p.totalRecipes),
              selectedIds: filter.value.publisherIds,
              onToggle: (id) => updateFilter((f) => f.copyWith(publisherIds: f.publisherIds.toggled(id))),
            ),
          ],
          _FilterSection<Equipment>(
            title: l10n.recipesEquipment,
            provider: _equipmentProvider(scope),
            itemMapper: (e) => (id: e.id, label: e.name, count: e.totalRecipes),
            selectedIds: filter.value.equipmentIds,
            onToggle: (id) => updateFilter((f) => f.copyWith(equipmentIds: f.equipmentIds.toggled(id))),
          ),
          const SizedBox(height: 80), // space for bottom button
        ],
      ),
      bottomNavigationBar: context.isMobile
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.paddingMedium),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, filter.value),
                  child: Text(context.l10n.recipesFilterApply),
                ),
              ),
            )
          : null,
    );

    // For mobile/bottom sheet, return full width. For desktop/side sheet, constrain width.
    if (context.isMobile) {
      return scaffold;
    } else {
      return SizedBox(
        width: 360,
        child: scaffold,
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UIConstants.paddingMedium,
        UIConstants.paddingMedium,
        UIConstants.paddingMedium,
        4,
      ),
      child: Text(title, style: context.textTheme.titleSmall),
    );
  }
}

class _FilterSection<T> extends ConsumerWidget {
  final String title;
  final ProviderListenable<AsyncValue<List<T>>> provider;
  final ({String id, String label, int? count}) Function(T) itemMapper;
  final List<String> selectedIds;
  final void Function(String) onToggle;

  const _FilterSection({
    required this.title,
    required this.provider,
    required this.itemMapper,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(provider)
        .when(
          data: (items) {
            if (items.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingMedium,
                    vertical: UIConstants.paddingSmall,
                  ),
                  child: Wrap(
                    spacing: UIConstants.paddingSmall,
                    runSpacing: UIConstants.paddingSmall,
                    children: items.map((item) {
                      final mapped = itemMapper(item);
                      final chipLabel = mapped.count != null ? '${mapped.label} (${mapped.count})' : mapped.label;
                      return FilterChip(
                        label: Text(chipLabel),
                        selected: selectedIds.contains(mapped.id),
                        onSelected: (_) => onToggle(mapped.id),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
          loading: () => LoadingWithMessage(message: context.l10n.recipesFilterLoading(title)),
          error: (e, s) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingMedium,
              vertical: UIConstants.paddingSmall,
            ),
            child: Text(
              context.l10n.recipesFilterLoadError(title),
              style: context.textTheme.bodySmall?.copyWith(color: context.colors.error),
            ),
          ),
        );
  }
}
