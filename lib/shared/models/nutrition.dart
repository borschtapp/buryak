import 'package:json_annotation/json_annotation.dart';

part 'nutrition.g.dart';

@JsonSerializable()
class Nutrition {
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

  Nutrition({
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
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) => _$NutritionFromJson(json);
  Map<String, dynamic> toJson() => _$NutritionToJson(this);

  Nutrition copyWith({
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
  }) {
    return Nutrition(
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
    );
  }
}
