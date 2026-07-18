import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';
part 'video.g.dart';

@freezed
abstract class Video with _$Video {
  const factory Video({
    String? name,
    String? description,
    String? embedUrl,
    String? contentUrl,
    String? thumbnailUrl,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
}
