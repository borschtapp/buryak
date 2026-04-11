import 'package:freezed_annotation/freezed_annotation.dart';

import 'shopping_item.dart';

part 'shopping_list.freezed.dart';
part 'shopping_list.g.dart';

@freezed
abstract class ShoppingList with _$ShoppingList {
  const factory ShoppingList({
    required String id,
    required String name,
    @JsonKey(name: 'is_default') bool? isDefault,

    // Preload fields
    List<ShoppingItem>? items,
  }) = _ShoppingList;

  factory ShoppingList.fromJson(Map<String, dynamic> json) => _$ShoppingListFromJson(json);
}
