import 'package:json_annotation/json_annotation.dart';

import 'shopping_item.dart';

part 'shopping_list.g.dart';

@JsonSerializable()
class ShoppingList {
  final String id;
  final String name;
  @JsonKey(name: 'is_default')
  final bool? isDefault;

  // Preload fields
  final List<ShoppingItem>? items;

  ShoppingList({
    required this.id,
    required this.name,
    this.isDefault,
    this.items,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) => _$ShoppingListFromJson(json);

  Map<String, dynamic> toJson() => _$ShoppingListToJson(this);

  ShoppingList copyWith({
    String? id,
    String? name,
    bool? isDefault,
    List<ShoppingItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      items: items ?? this.items,
    );
  }
}
