import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/extensions.dart';
import '../../shared/models/equipment.dart';
import '../../shared/models/recipe_filter.dart';
import '../../shared/models/taxonomy.dart';
import '../../shared/repositories/equipment_repository.dart';
import '../../shared/repositories/taxonomy_repository.dart';

part 'section_recipe_filters.g.dart';

@riverpod
Future<List<Taxonomy>> _taxonomiesByType(Ref ref, String type) async {
  final result = await ref.watch(taxonomyRepositoryProvider).findAll(type: type, limit: 100);
  return result.data;
}

@riverpod
Future<List<Equipment>> _equipment(Ref ref) async {
  final result = await ref.watch(equipmentRepositoryProvider).search(limit: 100);
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

  /// Called when filter changes. On desktop, set this to apply changes live.
  /// On mobile, leave null to require explicit "Apply" tap.
  final ValueChanged<RecipeFilter>? onFilterChanged;

  const RecipeFilters({
    super.key,
    required this.initialFilter,
    this.showTaxonomyFilters = true,
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

  void _toggleTaxonomy(String id) {
    setState(() {
      _filter = _filter.copyWith(
        taxonomyIds: _filter.taxonomyIds.toggled(id),
      );
      widget.onFilterChanged?.call(_filter);
    });
  }

  void _toggleEquipment(String id) {
    setState(() {
      _filter = _filter.copyWith(
        equipmentIds: _filter.equipmentIds.toggled(id),
      );
      widget.onFilterChanged?.call(_filter);
    });
  }

  void _setSort(SortField field, SortOrder order) {
    setState(() {
      _filter = _filter.copyWith(sort: field.name, order: order.name);
      widget.onFilterChanged?.call(_filter);
    });
  }

  void _setCookTimeMax(int? seconds) {
    setState(() {
      _filter = _filter.copyWith(cookTimeMax: seconds);
      widget.onFilterChanged?.call(_filter);
    });
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
                final isSelected = _filter.sort == opt.field.name && _filter.order == opt.order.name;
                return FilterChip(
                  label: Text(opt.label),
                  selected: isSelected,
                  onSelected: (_) => _setSort(opt.field, opt.order),
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
                  onChanged: (value) {
                    if (value == 0) {
                      _setCookTimeMax(null);
                    } else {
                      _setCookTimeMax(value.toInt());
                    }
                  },
                ),
              ],
            ),
          ),
          if (widget.showTaxonomyFilters) ...[
            _TaxonomySection(
              title: 'Cuisine',
              type: 'cuisine',
              selectedIds: _filter.taxonomyIds,
              onToggle: _toggleTaxonomy,
            ),
            _TaxonomySection(
              title: 'Diet',
              type: 'diet',
              selectedIds: _filter.taxonomyIds,
              onToggle: _toggleTaxonomy,
            ),
            _TaxonomySection(
              title: 'Category',
              type: 'category',
              selectedIds: _filter.taxonomyIds,
              onToggle: _toggleTaxonomy,
            ),
          ],
          _EquipmentSection(
            selectedIds: _filter.equipmentIds,
            onToggle: _toggleEquipment,
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

class _TaxonomySection extends ConsumerWidget {
  final String title;
  final String type;
  final List<String> selectedIds;
  final void Function(String id) onToggle;

  const _TaxonomySection({
    required this.title,
    required this.type,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_taxonomiesByTypeProvider(type));

    return async.when(
      data: (taxonomies) {
        if (taxonomies.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: taxonomies.map((t) {
                  final label = t.label ?? t.slug ?? t.id;
                  return FilterChip(
                    label: Text(label),
                    selected: selectedIds.contains(t.id),
                    onSelected: (_) => onToggle(t.id),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Text('Loading $title...', style: context.textTheme.bodySmall),
          ],
        ),
      ),
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

class _EquipmentSection extends ConsumerWidget {
  final List<String> selectedIds;
  final void Function(String id) onToggle;

  const _EquipmentSection({
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_equipmentProvider);

    return async.when(
      data: (equipment) {
        if (equipment.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader('Equipment'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: equipment.map((e) {
                  return FilterChip(
                    label: Text(e.name),
                    selected: selectedIds.contains(e.id),
                    onSelected: (_) => onToggle(e.id),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Text('Loading Equipment...', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      error: (e, s) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Text(
          'Failed to load Equipment',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
