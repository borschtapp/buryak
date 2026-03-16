import 'package:json_annotation/json_annotation.dart';
import 'image.dart';

part 'publisher.g.dart';

@JsonSerializable()
class Publisher {
  final String id;
  final String name;
  final String? description;
  final String url;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  // Preload fields
  final List<Image>? images;
  @JsonKey(name: 'total_recipes')
  final int? totalRecipes;

  Publisher({
    required this.id,
    required this.name,
    this.description,
    required this.url,
    this.imageUrl,
    this.images,
    this.totalRecipes,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) => _$PublisherFromJson(json);
  Map<String, dynamic> toJson() => _$PublisherToJson(this);
}
