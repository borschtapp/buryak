import 'package:json_annotation/json_annotation.dart';

part 'uploaded_image.g.dart';

@JsonSerializable()
class UploadedImage {
  final String url;
  final int? width;
  final int? height;
  final int? size;
  @JsonKey(name: 'content_type')
  final String? contentType;

  UploadedImage({
    required this.url,
    this.width,
    this.height,
    this.size,
    this.contentType,
  });

  factory UploadedImage.fromJson(Map<String, dynamic> json) => _$UploadedImageFromJson(json);

  Map<String, dynamic> toJson() => _$UploadedImageToJson(this);
}
