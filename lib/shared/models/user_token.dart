import 'package:json_annotation/json_annotation.dart';

part 'user_token.g.dart';

@JsonSerializable()
class UserToken {
  final String id;
  final String token;
  final String type;
  final String expires;
  @JsonKey(name: 'user_id')
  final String? userId;

  UserToken({
    required this.id,
    required this.token,
    required this.type,
    required this.expires,
    this.userId,
  });

  factory UserToken.fromJson(Map<String, dynamic> json) => _$UserTokenFromJson(json);
  Map<String, dynamic> toJson() => _$UserTokenToJson(this);
}
