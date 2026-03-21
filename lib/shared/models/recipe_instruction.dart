import 'package:json_annotation/json_annotation.dart';

part 'recipe_instruction.g.dart';

@JsonSerializable()
class RecipeInstruction {
  final String id;
  final int? order;
  final String? title;
  final String text;
  final String? url;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @JsonKey(name: 'parent_id')
  final String? parentId;

  // Preload fields
  final RecipeInstruction? parent;

  RecipeInstruction({
    required this.id,
    this.order,
    this.title,
    required this.text,
    this.url,
    this.imageUrl,
    this.videoUrl,
    this.parentId,
    this.parent,
  });

  factory RecipeInstruction.fromJson(Map<String, dynamic> json) => _$RecipeInstructionFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeInstructionToJson(this);
}
