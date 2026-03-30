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
    @JsonKey(name: 'last_sync_at') String? lastSyncAt,
    @JsonKey(name: 'last_sync_success') bool? lastSyncSuccess,

    // Preload fields
    @JsonKey(name: 'total_recipes') int? totalRecipes,
    @JsonKey(name: 'publisher_id') String? publisherId,
    Publisher? publisher,
    List<Recipe>? recipes,
  }) = _Feed;

  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
}
