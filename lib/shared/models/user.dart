import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

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

  static Map<String, dynamic> decodeJwt(String token) {
    final payload = token.split('.')[1];
    final padded = payload.padRight((payload.length + 3) & ~3, '=');
    return jsonDecode(utf8.decode(base64Url.decode(padded))) as Map<String, dynamic>;
  }

  bool isValidAccessToken() {
    final token = accessToken;
    if (token == null || token.isEmpty) return false;
    try {
      final jwtData = User.decodeJwt(token);
      return (jwtData['exp'] as int) * 1000 > DateTime.now().millisecondsSinceEpoch;
    } catch (_) {
      return false;
    }
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
