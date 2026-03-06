import 'package:buryak/shared/providers/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:json_annotation/json_annotation.dart';
import 'household.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  String email;
  String name;
  String? image;
  DateTime updated;
  DateTime created;
  @JsonKey(name: 'access_token')
  String accessToken;
  @JsonKey(name: 'refresh_token')
  String refreshToken;
  @JsonKey(name: 'household_id')
  String? householdId;
  Household? household;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    required this.updated,
    required this.created,
    required this.accessToken,
    required this.refreshToken,
    this.householdId,
    this.household,
  }) {
    getNewToken();
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool isValidAccessToken() {
    final jwtData = JwtDecoder.decode(accessToken);
    return jwtData['exp'] * 1000 > DateTime.now().millisecondsSinceEpoch;
  }

  void getNewToken() async {
    final jwtData = JwtDecoder.decode(accessToken);
    int exp = jwtData['exp'];
    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int waitSeconds = exp - now;

    if (waitSeconds > 0) {
      await Future.delayed(
        Duration(seconds: waitSeconds),
        () async {
          try {
            await UserService.refreshLogin();
          } catch (e) {
            // ignore
          }
        },
      );
    }
    getNewToken();
  }
}
