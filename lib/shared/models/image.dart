import 'package:json_annotation/json_annotation.dart';

part 'image.g.dart';

@JsonSerializable()
class Image {
  final String id;
  final String? url;
  final int? width;
  final int? height;
  @JsonKey(name: 'content_type')
  final String? contentType;
  final int? size;
  final String? caption;
  final int? order;

  Image({
    required this.id,
    this.url,
    this.width,
    this.height,
    this.contentType,
    this.size,
    this.caption,
    this.order,
  });

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

  Map<String, dynamic> toJson() => _$ImageToJson(this);
}
