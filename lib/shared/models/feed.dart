import 'package:freezed_annotation/freezed_annotation.dart';

import 'publisher.dart';
import 'recipe.dart';

part 'feed.freezed.dart';
part 'feed.g.dart';

@freezed
abstract class Feed with _$Feed {
  const factory Feed({
    required String id,
    required bool active,
    required String url,
    required String name,
    String? lastSyncAt,
    bool? lastSyncSuccess,

    // Preload fields
    int? totalRecipes,
    String? publisherId,
    Publisher? publisher,
    List<Recipe>? recipes,
  }) = _Feed;

  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
}
