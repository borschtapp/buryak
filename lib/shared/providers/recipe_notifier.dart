import 'package:flutter/material.dart';

class RecipeRefreshNotifier extends ChangeNotifier {
  static final RecipeRefreshNotifier _instance = RecipeRefreshNotifier._internal();
  factory RecipeRefreshNotifier() => _instance;
  RecipeRefreshNotifier._internal();

  String? lastAction;
  String? lastRecipeId;
  dynamic lastData;

  void notify({String? action, String? recipeId, dynamic data}) {
    lastAction = action;
    lastRecipeId = recipeId;
    lastData = data;
    notifyListeners();
  }
}
