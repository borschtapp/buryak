import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  @JsonKey(name: 'household_id')
  final String householdId;
  final String email;
  final String name;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'access_token')
  final String? accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  User({
    required this.id,
    required this.householdId,
    required this.name,
    required this.email,
    this.imageUrl,
    this.accessToken,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Standard [toJson] excludes tokens to prevent accidental exposure in logs/feeds.
  Map<String, dynamic> toJson() => _$UserToJson(this)
    ..remove('access_token')
    ..remove('refresh_token');

  /// Used for secure storage where tokens are required.
  Map<String, dynamic> toFullJson() => _$UserToJson(this);

  User copyWith({
    String? name,
    String? email,
    String? imageUrl,
    String? accessToken,
    String? refreshToken,
    String? householdId,
  }) {
    return User(
      id: id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

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
}
