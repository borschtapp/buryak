import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';
part 'video.g.dart';

@freezed
abstract class Video with _$Video {
  const factory Video({
    String? name,
    String? description,
    @JsonKey(name: 'embed_url') String? embedUrl,
    @JsonKey(name: 'content_url') String? contentUrl,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
}
