import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/shopping_list_repository.dart';

part 'shopping.g.dart';

/// Provides the ID of the primary (default) shopping list.
/// This is cached to avoid redundant API calls when adding items.
@Riverpod(keepAlive: true)
Future<String> primaryShoppingListId(Ref ref) async {
  final listsResponse = await ref.read(shoppingListRepositoryProvider).findAll();
  final lists = listsResponse.data;

  if (lists.isEmpty) {
    // Create a default list if none exist
    final newList = await ref
        .read(shoppingListRepositoryProvider)
        .create(
          'Shopping List',
          isDefault: true,
        );
    return newList.id;
  }

  // Find the default list, or use the first one
  final primary = lists.firstWhere(
    (l) => l.isDefault ?? false,
    orElse: () => lists.first,
  );
  return primary.id;
}
