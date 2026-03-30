import 'package:freezed_annotation/freezed_annotation.dart';

part 'image.freezed.dart';

part 'image.g.dart';

@freezed
abstract class Image with _$Image {
  const factory Image({
    required String id,
    String? url,
    int? width,
    int? height,
    @JsonKey(name: 'content_type') String? contentType,
    int? size,
    String? caption,
    int? order,
  }) = _Image;

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
}
