import 'repository.dart';
import '../models/user.dart';

class UserRepository extends Repository {
  UserRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/auth',
    super.isAuth = true,
  });

  static Future<User> login(String email, String password) async {
    ResponseBody response =
        await UserRepository(
          method: RequestMethod.post,
          path: '/login',
          isAuth: false,
        ).sendRequest(
          body: {
            'email': email,
            'password': password,
          },
        );
    return User.fromJson(response);
  }

  static Future<User> register(String name, String email, String password) async {
    ResponseBody response =
        await UserRepository(
          method: RequestMethod.post,
          path: '/register',
          isAuth: false,
        ).sendRequest(
          body: {
            'name': name,
            'email': email,
            'password': password,
          },
        );
    return User.fromJson(response);
  }

  static Future<User> refreshToken(User user) async {
    ResponseBody response = await UserRepository(
      method: RequestMethod.post,
      path: '/refresh',
      isAuth: false,
    ).sendRequest(body: {'refresh_token': user.refreshToken});

    user.accessToken = response['access_token'];
    user.refreshToken = response['refresh_token'];
    return user;
  }

  static Future<User> findOne(String id) async {
    ResponseBody response = await UserRepository(
      method: RequestMethod.get,
      path: '/$id',
      module: '/api/v1/users',
    ).sendRequest();
    return User.fromJson(response);
  }

  static Future<User> update(String id, {String? name, String? email}) async {
    ResponseBody response =
        await UserRepository(
          method: RequestMethod.patch,
          path: '/$id',
          module: '/api/v1/users',
        ).sendRequest(
          body: {
            'name': ?name,
            'email': ?email,
          },
        );
    return User.fromJson(response);
  }

  static Future<void> delete(String id) async {
    await UserRepository(
      method: RequestMethod.delete,
      path: '/$id',
      module: '/api/v1/users',
    ).sendRequest();
  }
}
