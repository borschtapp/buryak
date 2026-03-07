// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Household _$HouseholdFromJson(Map<String, dynamic> json) => Household(
  id: json['id'] as String,
  name: json['name'] as String,
  members: (json['members'] as List<dynamic>?)
      ?.map((e) => User.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HouseholdToJson(Household instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'members': instance.members,
};
