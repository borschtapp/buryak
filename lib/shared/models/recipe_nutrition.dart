import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_nutrition.freezed.dart';
part 'recipe_nutrition.g.dart';

@freezed
abstract class RecipeNutrition with _$RecipeNutrition {
  const RecipeNutrition._();

  const factory RecipeNutrition({
    String? servingSize,
    double? calories,
    double? carbs,
    double? carbsFiber,
    double? carbsSugar,
    double? cholesterol,
    double? fat,
    double? fatSaturated,
    double? fatTrans,
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
