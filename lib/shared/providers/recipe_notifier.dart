import 'package:flutter/material.dart';

class RecipeRefreshNotifier extends ChangeNotifier {
  static final RecipeRefreshNotifier _instance = RecipeRefreshNotifier._internal();
  factory RecipeRefreshNotifier() => _instance;
  RecipeRefreshNotifier._internal();

  void notify() {
    notifyListeners();
  }
}
