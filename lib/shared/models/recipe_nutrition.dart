import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_nutrition.freezed.dart';

part 'recipe_nutrition.g.dart';

@freezed
abstract class RecipeNutrition with _$RecipeNutrition {
  const RecipeNutrition._();

  const factory RecipeNutrition({
    @JsonKey(name: 'serving_size') String? servingSize,
    double? calories,
    double? carbs,
    @JsonKey(name: 'carbs_fiber') double? carbsFiber,
    @JsonKey(name: 'carbs_sugar') double? carbsSugar,
    double? cholesterol,
    double? fat,
    @JsonKey(name: 'fat_saturated') double? fatSaturated,
    @JsonKey(name: 'fat_trans') double? fatTrans,
    double? protein,
    double? sodium,
    double? calcium,
    double? copper,
    double? iron,
    double? magnesium,
    double? manganese,
    double? phosphorus,
    double? potassium,
    double? selenium,
    double? salt,
    double? zinc,
  }) = _RecipeNutrition;

  bool get hasData =>
      calories != null ||
      protein != null ||
      fat != null ||
      carbs != null ||
      fatSaturated != null ||
      carbsFiber != null ||
      carbsSugar != null ||
      sodium != null;

  factory RecipeNutrition.fromJson(Map<String, dynamic> json) => _$RecipeNutritionFromJson(json);
}
