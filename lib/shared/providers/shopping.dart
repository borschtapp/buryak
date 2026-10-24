import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/shopping_list_repository.dart';
import 'user.dart';

part 'shopping.g.dart';

/// Provides the ID of the primary (default) shopping list. Cached to avoid
/// redundant API calls, and recomputed whenever the session changes.
@Riverpod(keepAlive: true)
Future<String> primaryShoppingListId(Ref ref) async {
  ref.watchSession();

  // The server creates the default list together with the household.
  final lists = (await ref.read(shoppingListRepositoryProvider).findAll()).data;
  return lists.firstWhere((l) => l.isDefault ?? false, orElse: () => lists.first).id;
}
