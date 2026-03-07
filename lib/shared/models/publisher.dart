import 'package:json_annotation/json_annotation.dart';

part 'publisher.g.dart';

@JsonSerializable()
class Publisher {
  final String id;
  final String name;
  final String? url;
  final String? description;
  final String? image;

  @JsonKey(name: 'total_recipes')
  final int? totalRecipes;

  Publisher({
    required this.id,
    required this.name,
    this.url,
    this.description,
    this.image,
    this.totalRecipes,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) => _$PublisherFromJson(json);
  Map<String, dynamic> toJson() => _$PublisherToJson(this);
}
