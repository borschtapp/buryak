import 'repository.dart';
import '../models/user.dart';

class UserRepository extends Repository {
  UserRepository({required super.method, super.path = '', super.module = '', super.isAuth = true});

  static Future<User> login(String email, password) async {
    ResponseBody response = await UserRepository(method: RequestMethod.post, path: '/login', isAuth: false)
        .sendRequest(body: {'email': email, 'password': password});
    return User.fromJson(response);
  }

  static Future<User> oauthLogin(String provider, token) async {
    ResponseBody response = await UserRepository(method: RequestMethod.post, path: '/oauth/login', isAuth: false)
        .sendRequest(body: {'provider': provider, 'token': token});
    return User.fromJson(response);
  }

  static Future<User> register(String name, email, password) async {
    ResponseBody response = await UserRepository(method: RequestMethod.post, path: '/users', isAuth: false)
        .sendRequest(body: {'name': name, 'email': email, 'password': password});
    return User.fromJson(response);
  }

  static Future<User> refreshToken(User user) async {
    ResponseBody response = await UserRepository(method: RequestMethod.post, path: '/token/refresh', isAuth: false)
        .sendRequest(body: {'refresh_token': user.refreshToken});

    user.accessToken = response['access_token'];
    user.refreshToken = response['refresh_token'];
    return user;
  }
}
