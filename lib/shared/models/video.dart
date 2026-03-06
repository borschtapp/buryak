import 'package:json_annotation/json_annotation.dart';

part 'video.g.dart';

@JsonSerializable()
class Video {
  final String? name;
  final String? description;
  @JsonKey(name: 'embed_url')
  final String? embedUrl;
  @JsonKey(name: 'content_url')
  final String? contentUrl;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  Video({
    this.name,
    this.description,
    this.embedUrl,
    this.contentUrl,
    this.thumbnailUrl,
  });

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
  Map<String, dynamic> toJson() => _$VideoToJson(this);
}
