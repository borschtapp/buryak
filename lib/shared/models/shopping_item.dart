import 'package:json_annotation/json_annotation.dart';

import 'food.dart';
import 'unit.dart';

part 'shopping_item.g.dart';

@JsonSerializable()
class ShoppingItem {
  final String id;
  final String? text;
  final double? amount;
  @JsonKey(name: 'food_id')
  final String? foodId;
  @JsonKey(name: 'unit_id')
  final String? unitId;
  @JsonKey(name: 'is_bought')
  final bool? isBought;

  // Preload fields
  final Unit? unit;
  final Food? food;

  ShoppingItem({
    required this.id,
    this.text,
    this.amount,
    this.foodId,
    this.food,
    this.unitId,
    this.unit,
    this.isBought,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => _$ShoppingItemFromJson(json);

  Map<String, dynamic> toJson() => _$ShoppingItemToJson(this);

  ShoppingItem copyWith({
    String? id,
    bool? isBought,
    String? text,
    double? amount,
    Food? food,
    String? foodId,
    Unit? unit,
    String? unitId,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      isBought: isBought ?? this.isBought,
      text: text ?? this.text,
      amount: amount ?? this.amount,
      food: food ?? this.food,
      foodId: foodId ?? this.foodId,
      unit: unit ?? this.unit,
      unitId: unitId ?? this.unitId,
    );
  }
}
