import 'package:freezed_annotation/freezed_annotation.dart';

import 'unit.dart';

part 'food_unit_conversion.freezed.dart';
part 'food_unit_conversion.g.dart';

@freezed
abstract class FoodUnitConversion with _$FoodUnitConversion {
  const factory FoodUnitConversion({
    required String id,
    @JsonKey(name: 'food_id') required String foodId,
    @JsonKey(name: 'unit_id') String? unitId,
    @JsonKey(name: 'target_unit_id') required String targetUnitId,
    @JsonKey(name: 'target_amount') required double targetAmount,

    // Preload fields
    Unit? unit,
    @JsonKey(name: 'target_unit') Unit? targetUnit,
  }) = _FoodUnitConversion;

  factory FoodUnitConversion.fromJson(Map<String, dynamic> json) => _$FoodUnitConversionFromJson(json);
}
