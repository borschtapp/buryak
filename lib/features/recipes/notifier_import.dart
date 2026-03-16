import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../shared/models/recipe.dart';
import '../../shared/repositories/recipe_repository.dart';

part 'notifier_import.g.dart';

@riverpod
class ImportNotifier extends _$ImportNotifier {
  @override
  AsyncValue<Recipe?> build() {
    return const AsyncData(null);
  }

  Future<void> import(String url) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(recipeRepositoryProvider).import(url));
  }
}
