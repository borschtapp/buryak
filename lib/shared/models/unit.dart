import 'package:freezed_annotation/freezed_annotation.dart';

import 'taxonomy.dart';

part 'unit.freezed.dart';

part 'unit.g.dart';

@freezed
abstract class Unit with _$Unit {
  const factory Unit({
    required String id,
    required String slug,
    required String name,

    // Preload fields
    List<Taxonomy>? taxonomies,
  }) = _Unit;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
}
