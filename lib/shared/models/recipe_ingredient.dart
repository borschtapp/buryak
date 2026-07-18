import 'package:freezed_annotation/freezed_annotation.dart';

import '../util/extensions.dart';
import 'food.dart';
import 'unit.dart';

part 'recipe_ingredient.freezed.dart';
part 'recipe_ingredient.g.dart';

@freezed
abstract class RecipeIngredient with _$RecipeIngredient {
  const RecipeIngredient._();

  const factory RecipeIngredient({
    required String id,
    double? amount,
    double? maxAmount,
    String? name,
    String? category,
    String? description,
    String? rawText,
    String? foodId,
    String? unitId,

    // Preload fields
    Food? food,
    Unit? unit,
  }) = _RecipeIngredient;

  String get displayName => name ?? food?.name ?? rawText ?? description ?? 'Unknown ingredient';

  String get displayAmount => displayScaledAmount(1.0);

  String displayScaledAmount(double scale) {
    final scaledAmount = (amount != null && amount != 0) ? amount! * scale : null;
    final scaledMax = (maxAmount != null && maxAmount != 0) ? maxAmount! * scale : null;
    return [
      if (scaledAmount != null) scaledMax != null ? '${scaledAmount.displayAmount}-${scaledMax.displayAmount}' : scaledAmount.displayAmount,
      if (unit?.name.trim().isNotEmpty == true) unit!.name,
    ].where((s) => s.isNotEmpty).join(' ');
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => _$RecipeIngredientFromJson(json);
}
