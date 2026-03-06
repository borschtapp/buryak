import 'package:json_annotation/json_annotation.dart';

part 'recipe_image.g.dart';

@JsonSerializable()
class RecipeImage {
  final String? url;
  final int? width;
  final int? height;
  final String? caption;

  RecipeImage({
    this.url,
    this.width,
    this.height,
    this.caption,
  });

  factory RecipeImage.fromJson(Map<String, dynamic> json) => _$RecipeImageFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeImageToJson(this);
}
