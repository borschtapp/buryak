import 'package:json_annotation/json_annotation.dart';
import 'shopping_item.dart';

part 'shopping_list.g.dart';

@JsonSerializable()
class ShoppingList {
  final String id;
  final String name;
  @JsonKey(name: 'household_id')
  final String? householdId;
  @JsonKey(name: 'is_default')
  final bool? isDefault;

  // Preload fields
  final List<ShoppingItem>? items;

  ShoppingList({
    required this.id,
    required this.name,
    this.householdId,
    this.isDefault,
    this.items,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) => _$ShoppingListFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingListToJson(this);
}
