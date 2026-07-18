import 'package:freezed_annotation/freezed_annotation.dart';

import 'unit.dart';

part 'food_unit_conversion.freezed.dart';
part 'food_unit_conversion.g.dart';

@freezed
abstract class FoodUnitConversion with _$FoodUnitConversion {
  const factory FoodUnitConversion({
    required String id,
    required String foodId,
    String? unitId,
    required String targetUnitId,
    required double targetAmount,

    // Preload fields
    Unit? unit,
    Unit? targetUnit,
  }) = _FoodUnitConversion;

  factory FoodUnitConversion.fromJson(Map<String, dynamic> json) => _$FoodUnitConversionFromJson(json);
}
