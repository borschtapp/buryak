import 'package:freezed_annotation/freezed_annotation.dart';

import 'unit.dart';

part 'food_unit_conversion.freezed.dart';
part 'food_unit_conversion.g.dart';

@freezed
abstract class FoodUnitConversion with _$FoodUnitConversion {
  const FoodUnitConversion._();

  const factory FoodUnitConversion({
    required String id,
    required String foodId,
    required String unitId,
    required String targetUnitId,
    required double targetAmount,

    // Preload fields
    Unit? unit,
    Unit? targetUnit,
  }) = _FoodUnitConversion;

  /// The source unit, preloaded or looked up in [unitsById].
  Unit? sourceUnitIn(Map<String, Unit> unitsById) => unit ?? unitsById[unitId];

  /// The target unit, preloaded or looked up in [unitsById].
  Unit? targetUnitIn(Map<String, Unit> unitsById) => targetUnit ?? unitsById[targetUnitId];

  factory FoodUnitConversion.fromJson(Map<String, dynamic> json) => _$FoodUnitConversionFromJson(json);
}

extension FoodUnitConversionLookup on Iterable<FoodUnitConversion> {
  /// The conversion from [unitId]: a food has at most one per source unit.
  FoodUnitConversion? fromUnit(String unitId) => where((c) => c.unitId == unitId).firstOrNull;

  /// A conversion the server converts amounts in [from] to [to] with.
  FoodUnitConversion? linking(Unit from, Unit to, Map<String, Unit> unitsById) => where((c) {
    final (source, target) = (c.sourceUnitIn(unitsById), c.targetUnitIn(unitsById));
    return source != null && target != null && conversionLinks(source, target, from: from, to: to);
  }).firstOrNull;
}
