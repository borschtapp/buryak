// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserToken _$UserTokenFromJson(Map<String, dynamic> json) => UserToken(
  id: json['id'] as String,
  token: json['token'] as String,
  type: json['type'] as String,
  expires: json['expires'] as String,
  userId: json['userID'] as String?,
);

Map<String, dynamic> _$UserTokenToJson(UserToken instance) => <String, dynamic>{
  'id': instance.id,
  'token': instance.token,
  'type': instance.type,
  'expires': instance.expires,
  'userID': instance.userId,
};
