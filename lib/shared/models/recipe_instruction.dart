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
    String? imageUrl,
    String? videoUrl,
    String? parentId,

    // Preload fields
    RecipeInstruction? parent,
  }) = _RecipeInstruction;

  factory RecipeInstruction.fromJson(Map<String, dynamic> json) => _$RecipeInstructionFromJson(json);
}
