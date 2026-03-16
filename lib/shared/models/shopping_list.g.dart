// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShoppingList _$ShoppingListFromJson(Map<String, dynamic> json) => ShoppingList(
  id: json['id'] as String,
  name: json['name'] as String,
  householdId: json['household_id'] as String?,
  isDefault: json['is_default'] as bool?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ShoppingListToJson(ShoppingList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'household_id': instance.householdId,
      'is_default': instance.isDefault,
      'items': instance.items,
    };
