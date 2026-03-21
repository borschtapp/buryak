import 'package:flutter/foundation.dart';

enum SortField {
  id,
  name;
}

enum SortOrder {
  asc,
  desc;
}

@immutable
class RecipeFilter {
  final String? q;
  final List<String> taxonomyIds;
  final List<String> publisherIds;
  final List<String> authorIds;
  final List<String> equipmentIds;
  final int? cookTimeMax;
  final int? totalTimeMax;
  final String sort;
  final String order;

  const RecipeFilter({
    this.q,
    this.taxonomyIds = const [],
    this.publisherIds = const [],
    this.authorIds = const [],
    this.equipmentIds = const [],
    this.cookTimeMax,
    this.totalTimeMax,
    this.sort = 'id', // SortField.id.name
    this.order = 'desc', // SortOrder.desc.name
  });

  bool get isEmpty =>
      (q == null || q!.isEmpty) &&
      taxonomyIds.isEmpty &&
      publisherIds.isEmpty &&
      authorIds.isEmpty &&
      equipmentIds.isEmpty &&
      cookTimeMax == null &&
      totalTimeMax == null &&
      sort == SortField.id.name &&
      order == SortOrder.desc.name;

  int get activeCount =>
      (q != null && q!.isNotEmpty ? 1 : 0) +
      taxonomyIds.length +
      publisherIds.length +
      authorIds.length +
      equipmentIds.length +
      (cookTimeMax != null ? 1 : 0) +
      (totalTimeMax != null ? 1 : 0) +
      (sort != SortField.id.name || order != SortOrder.desc.name ? 1 : 0);

  /// Active filter count excluding the search query
  int get activeCountExcludingSearch =>
      taxonomyIds.length +
      publisherIds.length +
      authorIds.length +
      equipmentIds.length +
      (cookTimeMax != null ? 1 : 0) +
      (totalTimeMax != null ? 1 : 0) +
      (sort != SortField.id.name || order != SortOrder.desc.name ? 1 : 0);

  String? get taxonomiesParam =>
      taxonomyIds.isEmpty ? null : taxonomyIds.join(',');
  String? get publishersParam =>
      publisherIds.isEmpty ? null : publisherIds.join(',');
  String? get authorsParam =>
      authorIds.isEmpty ? null : authorIds.join(',');
  String? get equipmentParam =>
      equipmentIds.isEmpty ? null : equipmentIds.join(',');

  RecipeFilter copyWith({
    Object? q = _sentinel,
    List<String>? taxonomyIds,
    List<String>? publisherIds,
    List<String>? authorIds,
    List<String>? equipmentIds,
    Object? cookTimeMax = _sentinel,
    Object? totalTimeMax = _sentinel,
    String? sort,
    String? order,
  }) {
    return RecipeFilter(
      q: identical(q, _sentinel) ? this.q : q as String?,
      taxonomyIds: taxonomyIds ?? this.taxonomyIds,
      publisherIds: publisherIds ?? this.publisherIds,
      authorIds: authorIds ?? this.authorIds,
      equipmentIds: equipmentIds ?? this.equipmentIds,
      cookTimeMax: identical(cookTimeMax, _sentinel) ? this.cookTimeMax : cookTimeMax as int?,
      totalTimeMax: identical(totalTimeMax, _sentinel) ? this.totalTimeMax : totalTimeMax as int?,
      sort: sort ?? this.sort,
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeFilter &&
          q == other.q &&
          listEquals(taxonomyIds, other.taxonomyIds) &&
          listEquals(publisherIds, other.publisherIds) &&
          listEquals(authorIds, other.authorIds) &&
          listEquals(equipmentIds, other.equipmentIds) &&
          cookTimeMax == other.cookTimeMax &&
          totalTimeMax == other.totalTimeMax &&
          sort == other.sort &&
          order == other.order;

  @override
  int get hashCode => Object.hash(
      q,
      Object.hashAll(taxonomyIds),
      Object.hashAll(publisherIds),
      Object.hashAll(authorIds),
      Object.hashAll(equipmentIds),
      cookTimeMax,
      totalTimeMax,
      sort,
      order);
}

const _sentinel = Object();
