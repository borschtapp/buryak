import 'package:json_annotation/json_annotation.dart';

part 'recipe_nutrition.g.dart';

@JsonSerializable()
class RecipeNutrition {
  @JsonKey(name: 'serving_size')
  final String? servingSize;
  final double? calories;
  final double? carbs;
  @JsonKey(name: 'carbs_fiber')
  final double? carbsFiber;
  @JsonKey(name: 'carbs_sugar')
  final double? carbsSugar;
  final double? cholesterol;
  final double? fat;
  @JsonKey(name: 'fat_saturated')
  final double? fatSaturated;
  @JsonKey(name: 'fat_trans')
  final double? fatTrans;
  final double? protein;
  final double? sodium;
  final double? calcium;
  final double? copper;
  final double? iron;
  final double? magnesium;
  final double? manganese;
  final double? phosphorus;
  final double? potassium;
  final double? selenium;
  final double? salt;
  final double? zinc;

  RecipeNutrition({
    this.servingSize,
    this.calories,
    this.carbs,
    this.carbsFiber,
    this.carbsSugar,
    this.cholesterol,
    this.fat,
    this.fatSaturated,
    this.fatTrans,
    this.protein,
    this.sodium,
    this.calcium,
    this.copper,
    this.iron,
    this.magnesium,
    this.manganese,
    this.phosphorus,
    this.potassium,
    this.selenium,
    this.salt,
    this.zinc,
  });

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
  Map<String, dynamic> toJson() => _$RecipeNutritionToJson(this);

  RecipeNutrition copyWith({
    double? calories,
    double? carbs,
    double? carbsFiber,
    double? carbsSugar,
    double? cholesterol,
    double? fat,
    double? fatSaturated,
    double? fatTrans,
    double? protein,
    String? servingSize,
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
  }) {
    return RecipeNutrition(
      calories: calories ?? this.calories,
      carbs: carbs ?? this.carbs,
      carbsFiber: carbsFiber ?? this.carbsFiber,
      carbsSugar: carbsSugar ?? this.carbsSugar,
      cholesterol: cholesterol ?? this.cholesterol,
      fat: fat ?? this.fat,
      fatSaturated: fatSaturated ?? this.fatSaturated,
      fatTrans: fatTrans ?? this.fatTrans,
      protein: protein ?? this.protein,
      servingSize: servingSize ?? this.servingSize,
      sodium: sodium ?? this.sodium,
      calcium: calcium ?? this.calcium,
      copper: copper ?? this.copper,
      iron: iron ?? this.iron,
      magnesium: magnesium ?? this.magnesium,
      manganese: manganese ?? this.manganese,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      selenium: selenium ?? this.selenium,
      salt: salt ?? this.salt,
      zinc: zinc ?? this.zinc,
    );
  }
}