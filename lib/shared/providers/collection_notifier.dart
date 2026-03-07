import 'package:flutter/material.dart';

class CollectionRefreshNotifier extends ChangeNotifier {
  static final CollectionRefreshNotifier _instance = CollectionRefreshNotifier._internal();

  factory CollectionRefreshNotifier() {
    return _instance;
  }

  CollectionRefreshNotifier._internal();

  void notify() {
    notifyListeners();
  }
}
