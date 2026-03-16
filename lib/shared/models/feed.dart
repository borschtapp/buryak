import 'package:json_annotation/json_annotation.dart';
import 'publisher.dart';
import 'recipe.dart';

part 'feed.g.dart';

@JsonSerializable()
class Feed {
  final String id;
  final bool active;
  final String url;
  final String name;
  @JsonKey(name: 'error_count')
  final int? errorCount;
  @JsonKey(name: 'last_sync_at')
  final String? lastSyncAt;
  @JsonKey(name: 'last_sync_success')
  final bool? lastSyncSuccess;
  final String? updated;
  final String? created;

  // Preload fields
  @JsonKey(name: 'total_recipes')
  final int? totalRecipes;
  final Publisher? publisher;
  final List<Recipe>? recipes;

  Feed({
    required this.id,
    required this.active,
    required this.url,
    required this.name,
    this.lastSyncAt,
    this.lastSyncSuccess,
    this.errorCount,
    this.updated,
    this.created,
    this.publisher,
    this.recipes,
    this.totalRecipes,
  });

  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
  Map<String, dynamic> toJson() => _$FeedToJson(this);
}
