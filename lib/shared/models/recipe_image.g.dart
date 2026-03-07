// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeImage _$RecipeImageFromJson(Map<String, dynamic> json) => RecipeImage(
  url: json['url'] as String?,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  caption: json['caption'] as String?,
);

Map<String, dynamic> _$RecipeImageToJson(RecipeImage instance) =>
    <String, dynamic>{
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
      'caption': instance.caption,
    };
