import 'package:buryak/shared/providers/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class User {
  final int id;
  String email;
  String name;
  String? image;
  DateTime updated;
  DateTime created;
  String accessToken;
  String refreshToken;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    required this.updated,
    required this.created,
    required this.accessToken,
    required this.refreshToken,
  }) {
    getNewToken();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      image: json['image'],
      updated: DateTime.parse(json['updated']),
      created: DateTime.parse(json['created']),
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'image': image,
    'updated': updated.toIso8601String(),
    'created': created.toIso8601String(),
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };

  bool isValidAccessToken() {
    final jwtData = JwtDecoder.decode(accessToken);
    return jwtData['exp'] < DateTime.now().millisecondsSinceEpoch;
  }

  void getNewToken() async {
    final jwtData = JwtDecoder.decode(accessToken);
    await Future.delayed(
      Duration(milliseconds: jwtData['exp'] * 1000 - DateTime.now().millisecondsSinceEpoch),
      () async {
        try {
          await UserService.refreshLogin();
        } catch (e) {}
      },
    );
    getNewToken();
  }
}
