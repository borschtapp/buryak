// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Household _$HouseholdFromJson(Map<String, dynamic> json) => Household(
  id: json['id'] as String,
  name: json['name'] as String,
  ownerId: json['owner_id'] as String?,
  members: (json['members'] as List<dynamic>?)
      ?.map((e) => User.fromJson(e as Map<String, dynamic>))
      .toList(),
  collections: (json['collections'] as List<dynamic>?)
      ?.map((e) => Collection.fromJson(e as Map<String, dynamic>))
      .toList(),
  feeds: (json['feeds'] as List<dynamic>?)
      ?.map((e) => Feed.fromJson(e as Map<String, dynamic>))
      .toList(),
  shoppingLists: (json['shopping_lists'] as List<dynamic>?)
      ?.map((e) => ShoppingList.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HouseholdToJson(Household instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'owner_id': instance.ownerId,
  'members': instance.members,
  'collections': instance.collections,
  'feeds': instance.feeds,
  'shopping_lists': instance.shoppingLists,
};
