import 'package:json_annotation/json_annotation.dart';

part 'author.g.dart';

@JsonSerializable()
class Author {
  final String? id;
  final String? name;
  final String? description;
  final String? url;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  Author({
    this.id,
    this.name,
    this.description,
    this.url,
    this.imageUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}
