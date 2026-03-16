import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/recipes/notifier_saved.dart';
import '../models/recipe.dart';

part 'saved.g.dart';

@riverpod
Set<String> savedRecipeIds(Ref ref) {
  final savedRecipesAsync = ref.watch(savedRecipesProvider);
  return savedRecipesAsync.when<Set<String>>(
    data: (List<Recipe> recipes) => recipes.where((r) => r.isSaved == true).map((r) => r.id).toSet(),
    loading: () => {},
    error: (err, stack) => {},
  );
}

@riverpod
bool recipeIsSaved(Ref ref, String recipeId) {
  return ref.watch(savedRecipeIdsProvider).contains(recipeId);
}
