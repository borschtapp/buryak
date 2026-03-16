// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_instruction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeInstruction _$RecipeInstructionFromJson(Map<String, dynamic> json) =>
    RecipeInstruction(
      id: json['id'] as String,
      order: (json['order'] as num?)?.toInt(),
      title: json['title'] as String?,
      text: json['text'] as String,
      url: json['url'] as String?,
      imageUrl: json['image_url'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => Image.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoUrl: json['video_url'] as String?,
      parentId: json['parent_id'] as String?,
      parent: json['parent'] == null
          ? null
          : RecipeInstruction.fromJson(json['parent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecipeInstructionToJson(RecipeInstruction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order': instance.order,
      'title': instance.title,
      'text': instance.text,
      'url': instance.url,
      'image_url': instance.imageUrl,
      'images': instance.images,
      'video_url': instance.videoUrl,
      'parent_id': instance.parentId,
      'parent': instance.parent,
    };
