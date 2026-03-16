// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  image: json['image'] as String?,
  updated: DateTime.parse(json['updated'] as String),
  created: DateTime.parse(json['created'] as String),
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  householdId: json['household_id'] as String?,
  household: json['household'] == null
      ? null
      : Household.fromJson(json['household'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'image': instance.image,
  'updated': instance.updated.toIso8601String(),
  'created': instance.created.toIso8601String(),
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'household_id': instance.householdId,
  'household': instance.household,
};
