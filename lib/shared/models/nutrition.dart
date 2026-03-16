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
}
