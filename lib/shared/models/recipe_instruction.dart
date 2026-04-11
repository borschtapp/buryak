import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_instruction.freezed.dart';
part 'recipe_instruction.g.dart';

@freezed
abstract class RecipeInstruction with _$RecipeInstruction {
  const factory RecipeInstruction({
    required String id,
    int? order,
    String? title,
    required String text,
    String? url,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'video_url') String? videoUrl,
    @JsonKey(name: 'parent_id') String? parentId,

    // Preload fields
    RecipeInstruction? parent,
  }) = _RecipeInstruction;

  factory RecipeInstruction.fromJson(Map<String, dynamic> json) => _$RecipeInstructionFromJson(json);
}
