import 'package:json_annotation/json_annotation.dart';

part 'recipe_instruction.g.dart';

@JsonSerializable()
class RecipeInstruction {
  final String id;
  final int? order;
  final String? title;
  final String text;
  final String? url;
  final String? image;
  final String? video;
  @JsonKey(name: 'parent_id')
  final String? parentId;
  final RecipeInstruction? parent;

  RecipeInstruction({
    required this.id,
    this.order,
    this.title,
    required this.text,
    this.url,
    this.image,
    this.video,
    this.parentId,
    this.parent,
  });

  factory RecipeInstruction.fromJson(Map<String, dynamic> json) => _$RecipeInstructionFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeInstructionToJson(this);
}
