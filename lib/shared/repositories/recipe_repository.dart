import 'dart:convert';

import 'package:http/http.dart';

import '../models/recipe.dart';
import '../providers/user.dart';
import 'repository.dart';

class RecipeRepository {
  static Future<List<Recipe>> findAll() async {
    Response response = await get(buildUri('/recipes'),
        headers: buildHeaders(accessToken: UserService.getAccessToken()));

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        return json.map<Recipe>((json) => Recipe.fromJson(json)).toList();
      case 400:
        final json = jsonDecode(response.body);
        throw handleFormErrors(json);
      case 300:
      case 500:
      default:
        throw FormGeneralException(message: 'Error contacting the server!');
    }
  }

  static Future<Recipe> findOne(int recipeId) async {
    Response response = await get(buildUri('/recipes/$recipeId'),
        headers: buildHeaders(accessToken: UserService.getAccessToken()));

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        return Recipe.fromJson(json);
      case 400:
        final json = jsonDecode(response.body);
        throw handleFormErrors(json);
      case 300:
      case 500:
      default:
        throw FormGeneralException(message: 'Error contacting the server!');
    }
  }

  static Future<List<Recipe>> explore() async {
    Response response = await get(buildUri('/recipes/explore'),
        headers: buildHeaders(accessToken: UserService.getAccessToken()));

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        return json.map<Recipe>((json) => Recipe.fromJson(json)).toList();
      case 400:
        final json = jsonDecode(response.body);
        throw handleFormErrors(json);
      case 300:
      case 500:
      default:
        throw FormGeneralException(message: 'Error contacting the server!');
    }
  }

  static Future<Recipe> scrape(String url) async {
    Response response = await get(buildUri('/recipes/scrape', {'url': url}),
        headers: buildHeaders(accessToken: UserService.getAccessToken()));

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        return Recipe.fromJson(json);
      case 400:
        final json = jsonDecode(response.body);
        throw handleFormErrors(json);
      case 300:
      case 500:
      default:
        throw FormGeneralException(message: 'Error contacting the server!');
    }
  }

  static Future<void> save(int recipeId) async {
    Response response = await post(buildUri('/recipes/$recipeId/save'),
        headers: buildHeaders(accessToken: UserService.getAccessToken()));

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        return;
      default:
        throw FormGeneralException(message: response.body);
    }
  }

  static Future<void> unsave(int recipeId) async {
    Response response = await delete(buildUri('/recipes/$recipeId/save'),
        headers: buildHeaders(accessToken: UserService.getAccessToken()));

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        return;
      default:
        throw FormGeneralException(message: response.body);
    }
  }
}
