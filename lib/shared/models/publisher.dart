import 'package:freezed_annotation/freezed_annotation.dart';

import 'feed.dart';
import 'recipe.dart';

part 'publisher.freezed.dart';

part 'publisher.g.dart';

@freezed
abstract class Publisher with _$Publisher {
  const factory Publisher({
    required String id,
    required String name,
    String? description,
    required String url,
    @JsonKey(name: 'image_url') String? imageUrl,

    // Preload fields
    @JsonKey(name: 'total_recipes') int? totalRecipes,
    List<Feed>? feeds,
    List<Recipe>? recipes,
  }) = _Publisher;

  factory Publisher.fromJson(Map<String, dynamic> json) => _$PublisherFromJson(json);
}
