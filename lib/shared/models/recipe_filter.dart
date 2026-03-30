import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_filter.freezed.dart';

enum SortField { id, name }

enum SortOrder { asc, desc }

@freezed
abstract class RecipeFilter with _$RecipeFilter {
  const RecipeFilter._();

  const factory RecipeFilter({
    String? q,
    @Default([]) List<String> taxonomyIds,
    @Default([]) List<String> publisherIds,
    @Default([]) List<String> authorIds,
    @Default([]) List<String> equipmentIds,
    int? cookTimeMax,
    int? totalTimeMax,
    @Default(SortField.id) SortField sort,
    @Default(SortOrder.desc) SortOrder order,
  }) = _RecipeFilter;

  bool get isEmpty =>
      (q == null || q!.isEmpty) &&
      taxonomyIds.isEmpty &&
      publisherIds.isEmpty &&
      authorIds.isEmpty &&
      equipmentIds.isEmpty &&
      cookTimeMax == null &&
      totalTimeMax == null &&
      sort == SortField.id &&
      order == SortOrder.desc;

  int get activeCount =>
      (q != null && q!.isNotEmpty ? 1 : 0) +
      taxonomyIds.length +
      publisherIds.length +
      authorIds.length +
      equipmentIds.length +
      (cookTimeMax != null ? 1 : 0) +
      (totalTimeMax != null ? 1 : 0) +
      (sort != SortField.id || order != SortOrder.desc ? 1 : 0);

  /// Active filter count excluding the search query
  int get activeCountExcludingSearch =>
      taxonomyIds.length +
      publisherIds.length +
      authorIds.length +
      equipmentIds.length +
      (cookTimeMax != null ? 1 : 0) +
      (totalTimeMax != null ? 1 : 0) +
      (sort != SortField.id || order != SortOrder.desc ? 1 : 0);

  String? get taxonomiesParam => taxonomyIds.isEmpty ? null : taxonomyIds.join(',');

  String? get publishersParam => publisherIds.isEmpty ? null : publisherIds.join(',');

  String? get authorsParam => authorIds.isEmpty ? null : authorIds.join(',');

  String? get equipmentParam => equipmentIds.isEmpty ? null : equipmentIds.join(',');
}
