import 'package:json_annotation/json_annotation.dart';
import 'unit.dart';

part 'shopping_list.g.dart';

@JsonSerializable()
class ShoppingList {
  final String id;
  @JsonKey(name: 'household_id')
  final String? householdId;
  @JsonKey(name: 'is_bought')
  final bool? isBought;
  final String? product;
  final double? quantity;
  final Unit? unit;
  @JsonKey(name: 'unit_id')
  final String? unitId;

  ShoppingList({
    required this.id,
    this.householdId,
    this.isBought,
    this.product,
    this.quantity,
    this.unit,
    this.unitId,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) => _$ShoppingListFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingListToJson(this);
}
