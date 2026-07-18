import 'package:freezed_annotation/freezed_annotation.dart';

part 'uploaded_image.freezed.dart';
part 'uploaded_image.g.dart';

@freezed
abstract class UploadedImage with _$UploadedImage {
  const factory UploadedImage({
    required String url,
    int? width,
    int? height,
    int? size,
    String? contentType,
  }) = _UploadedImage;

  factory UploadedImage.fromJson(Map<String, dynamic> json) => _$UploadedImageFromJson(json);
}
