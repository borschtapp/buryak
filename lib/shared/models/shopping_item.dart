import 'package:json_annotation/json_annotation.dart';
import 'food.dart';
import 'unit.dart';

part 'shopping_item.g.dart';

@JsonSerializable()
class ShoppingItem {
  final String id;
  @JsonKey(name: 'shopping_list_id')
  final String? shoppingListId;
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
    this.shoppingListId,
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
}
