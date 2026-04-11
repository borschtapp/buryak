import 'package:freezed_annotation/freezed_annotation.dart';

import 'food.dart';
import 'unit.dart';

part 'shopping_item.freezed.dart';
part 'shopping_item.g.dart';

@freezed
abstract class ShoppingItem with _$ShoppingItem {
  const factory ShoppingItem({
    required String id,
    String? text,
    double? amount,
    @JsonKey(name: 'food_id') String? foodId,
    @JsonKey(name: 'unit_id') String? unitId,
    @JsonKey(name: 'is_bought') bool? isBought,

    // Preload fields
    Unit? unit,
    Food? food,
  }) = _ShoppingItem;

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => _$ShoppingItemFromJson(json);
}
