import 'package:flutter/material.dart';

class FeedRefreshNotifier extends ChangeNotifier {
  static final FeedRefreshNotifier _instance = FeedRefreshNotifier._internal();
  factory FeedRefreshNotifier() => _instance;
  FeedRefreshNotifier._internal();

  String? lastAction;
  String? lastFeedId;
  dynamic lastData;

  void notify({String? action, String? feedId, dynamic data}) {
    lastAction = action;
    lastFeedId = feedId;
    lastData = data;
    notifyListeners();
  }
}
