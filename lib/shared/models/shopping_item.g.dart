// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShoppingItem _$ShoppingItemFromJson(Map<String, dynamic> json) => ShoppingItem(
  id: json['id'] as String,
  shoppingListId: json['shopping_list_id'] as String?,
  text: json['text'] as String?,
  amount: (json['amount'] as num?)?.toDouble(),
  foodId: json['food_id'] as String?,
  food: json['food'] == null
      ? null
      : Food.fromJson(json['food'] as Map<String, dynamic>),
  unitId: json['unit_id'] as String?,
  unit: json['unit'] == null
      ? null
      : Unit.fromJson(json['unit'] as Map<String, dynamic>),
  isBought: json['is_bought'] as bool?,
);

Map<String, dynamic> _$ShoppingItemToJson(ShoppingItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shopping_list_id': instance.shoppingListId,
      'text': instance.text,
      'amount': instance.amount,
      'food_id': instance.foodId,
      'food': instance.food,
      'unit_id': instance.unitId,
      'unit': instance.unit,
      'is_bought': instance.isBought,
    };
