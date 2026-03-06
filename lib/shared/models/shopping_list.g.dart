// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShoppingList _$ShoppingListFromJson(Map<String, dynamic> json) => ShoppingList(
  id: json['id'] as String,
  householdId: json['household_id'] as String?,
  isBought: json['is_bought'] as bool?,
  product: json['product'] as String?,
  quantity: (json['quantity'] as num?)?.toDouble(),
  unit: json['unit'] == null ? null : Unit.fromJson(json['unit'] as Map<String, dynamic>),
  unitId: json['unit_id'] as String?,
);

Map<String, dynamic> _$ShoppingListToJson(ShoppingList instance) => <String, dynamic>{
  'id': instance.id,
  'household_id': instance.householdId,
  'is_bought': instance.isBought,
  'product': instance.product,
  'quantity': instance.quantity,
  'unit': instance.unit,
  'unit_id': instance.unitId,
};
