import 'package:json_annotation/json_annotation.dart';
import 'recipe.dart';
import 'user.dart';

part 'feed.g.dart';

@JsonSerializable()
class Feed {
  final String id;
  final String url;
  final String? name;
  final String? description;
  @JsonKey(name: 'website_url')
  final String? websiteUrl;
  final bool? active;
  @JsonKey(name: 'last_fetched_at')
  final DateTime? lastFetchedAt;
  @JsonKey(name: 'error_count')
  final int? errorCount;
  final DateTime created;
  final DateTime updated;
  final List<Recipe>? recipes;
  final List<User>? users;

  Feed({
    required this.id,
    required this.url,
    this.name,
    this.description,
    this.websiteUrl,
    this.active,
    this.lastFetchedAt,
    this.errorCount,
    required this.created,
    required this.updated,
    this.recipes,
    this.users,
  });

  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
  Map<String, dynamic> toJson() => _$FeedToJson(this);
}
