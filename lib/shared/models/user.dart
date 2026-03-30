import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    @JsonKey(name: 'household_id') required String householdId,
    required String email,
    required String name,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'access_token', includeToJson: false) String? accessToken,
    @JsonKey(name: 'refresh_token', includeToJson: false) String? refreshToken,
  }) = _User;

  /// Used for secure storage where tokens are required.
  Map<String, dynamic> toFullJson() => {
    ...toJson(),
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };

  bool isValidAccessToken() {
    final token = accessToken;
    if (token == null || token.isEmpty) return false;
    try {
      final jwtData = JwtDecoder.decode(token);
      return (jwtData['exp'] as int) * 1000 > DateTime.now().millisecondsSinceEpoch;
    } catch (_) {
      return false;
    }
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
