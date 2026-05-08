import 'package:flutter/material.dart';
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

/// Sort options for recipe lists.
const _sortOptions = [
  (label: 'Newest', field: SortField.id, order: SortOrder.desc),
  (label: 'Oldest', field: SortField.id, order: SortOrder.asc),
  (label: 'Name A–Z', field: SortField.name, order: SortOrder.asc),
  (label: 'Name Z–A', field: SortField.name, order: SortOrder.desc),
];

class RecipeFilters extends StatefulWidget {
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
  State<RecipeFilters> createState() => _RecipeFiltersState();
}

class _RecipeFiltersState extends State<RecipeFilters> {
  late RecipeFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  void _updateFilter(RecipeFilter Function(RecipeFilter) updater) {
    final newFilter = updater(_filter);
    setState(() => _filter = newFilter);
    widget.onFilterChanged?.call(newFilter);
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        leading: context.isMobile
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () => setState(() {
                _filter = const RecipeFilter();
                widget.onFilterChanged?.call(_filter);
              }),
              child: const Text('Clear all'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionHeader('Sort by'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sortOptions.map((opt) {
                final isSelected = _filter.sort == opt.field && _filter.order == opt.order;
                return FilterChip(
                  label: Text(opt.label),
                  selected: isSelected,
                  onSelected: (_) => _updateFilter((f) => f.copyWith(sort: opt.field, order: opt.order)),
                );
              }).toList(),
            ),
          ),
          const _SectionHeader('Cook Time'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _filter.cookTimeMax == null ? 'Any time' : 'Up to ${(_filter.cookTimeMax! / 60).round()} minutes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Slider(
                  min: 0,
                  max: 3600,
                  divisions: 60,
                  value: _filter.cookTimeMax?.toDouble() ?? 0,
                  onChanged: (value) => _updateFilter(
                    (f) => f.copyWith(cookTimeMax: value == 0 ? null : value.toInt()),
                  ),
                ),
              ],
            ),
          ),
          if (widget.showTaxonomyFilters) ...[
            _FilterSection<Taxonomy>(
              title: 'Cuisine',
              provider: _taxonomiesByTypeProvider('cuisine', widget.scope),
              itemMapper: (t) => (id: t.id, label: t.label ?? t.slug ?? t.id, count: t.totalRecipes),
              selectedIds: _filter.taxonomyIds,
              onToggle: (id) => _updateFilter((f) => f.copyWith(taxonomyIds: f.taxonomyIds.toggled(id))),
            ),
            _FilterSection<Taxonomy>(
              title: 'Diet',
              provider: _taxonomiesByTypeProvider('diet', widget.scope),
              itemMapper: (t) => (id: t.id, label: t.label ?? t.slug ?? t.id, count: t.totalRecipes),
              selectedIds: _filter.taxonomyIds,
              onToggle: (id) => _updateFilter((f) => f.copyWith(taxonomyIds: f.taxonomyIds.toggled(id))),
            ),
            _FilterSection<Taxonomy>(
              title: 'Category',
              provider: _taxonomiesByTypeProvider('category', widget.scope),
              itemMapper: (t) => (id: t.id, label: t.label ?? t.slug ?? t.id, count: t.totalRecipes),
              selectedIds: _filter.taxonomyIds,
              onToggle: (id) => _updateFilter((f) => f.copyWith(taxonomyIds: f.taxonomyIds.toggled(id))),
            ),
            _FilterSection<Publisher>(
              title: 'Publisher',
              provider: _topPublishersProvider(widget.scope),
              itemMapper: (p) => (id: p.id, label: p.name, count: p.totalRecipes),
              selectedIds: _filter.publisherIds,
              onToggle: (id) => _updateFilter((f) => f.copyWith(publisherIds: f.publisherIds.toggled(id))),
            ),
          ],
          _FilterSection<Equipment>(
            title: 'Equipment',
            provider: _equipmentProvider(widget.scope),
            itemMapper: (e) => (id: e.id, label: e.name, count: e.totalRecipes),
            selectedIds: _filter.equipmentIds,
            onToggle: (id) => _updateFilter((f) => f.copyWith(equipmentIds: f.equipmentIds.toggled(id))),
          ),
          const SizedBox(height: 80), // space for bottom button
        ],
      ),
      bottomNavigationBar: context.isMobile
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, _filter),
                  child: const Text('Apply'),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
          loading: () => LoadingWithMessage(message: 'Loading $title...'),
          error: (e, s) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Failed to load $title',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
  }
}
