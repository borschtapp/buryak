import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_token.freezed.dart';

part 'user_token.g.dart';

@freezed
abstract class UserToken with _$UserToken {
  const factory UserToken({
    required String id,
    required String token,
    required String type,
    required String expires,
    @JsonKey(name: 'user_id') String? userId,
  }) = _UserToken;

  factory UserToken.fromJson(Map<String, dynamic> json) => _$UserTokenFromJson(json);
}
