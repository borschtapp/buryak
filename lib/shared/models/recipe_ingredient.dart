import 'package:freezed_annotation/freezed_annotation.dart';

import 'food.dart';
import 'unit.dart';
import '../util/extensions.dart';

part 'recipe_ingredient.freezed.dart';

part 'recipe_ingredient.g.dart';

@freezed
abstract class RecipeIngredient with _$RecipeIngredient {
  const RecipeIngredient._();

  const factory RecipeIngredient({
    required String id,
    double? amount,
    @JsonKey(name: 'max_amount') double? maxAmount,
    String? name,
    String? category,
    String? description,
    @JsonKey(name: 'raw_text') String? rawText,
    @JsonKey(name: 'food_id') String? foodId,
    @JsonKey(name: 'unit_id') String? unitId,

    // Preload fields
    Food? food,
    Unit? unit,
  }) = _RecipeIngredient;

  String get displayName => name ?? food?.name ?? rawText ?? description ?? 'Unknown ingredient';

  String get displayAmount {
    final hasMax = maxAmount != null && maxAmount != 0;
    return [
      if (amount != null && amount != 0) hasMax ? '${amount.displayAmount}-${maxAmount.displayAmount}' : amount.displayAmount,
      if (unit?.name.trim().isNotEmpty == true) unit!.name,
    ].where((s) => s.isNotEmpty).join(' ');
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => _$RecipeIngredientFromJson(json);
}
