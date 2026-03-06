import 'package:flutter/material.dart';

import '../../shared/extensions.dart';
import '../../shared/models/shopping_list.dart';
import '../../shared/repositories/shopping_list_repository.dart';
import '../../shared/views/async_loader.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  late Future<List<ShoppingList>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = ShoppingListRepository.findAll();
  }

  Future<void> _toggleItem(ShoppingList item) async {
    await ShoppingListRepository.update(
      item.id,
      isBought: !(item.isBought ?? false),
    );
    setState(() {
      _itemsFuture = ShoppingListRepository.findAll();
    });
  }

  Future<void> _deleteItem(ShoppingList item) async {
    await ShoppingListRepository.delete(item.id);
    setState(() {
      _itemsFuture = ShoppingListRepository.findAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<List<ShoppingList>>(
      future: _itemsFuture,
      builder: (context, items) {
        if (items.isEmpty) {
          return const Center(child: Text('Your shopping list is empty.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: Checkbox(
                value: item.isBought ?? false,
                onChanged: (_) => _toggleItem(item),
              ),
              title: Text(
                item.product ?? '',
                style: (item.isBought ?? false)
                    ? context.textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      )
                    : null,
              ),
              subtitle: item.quantity != null
                  ? Text(
                      '${item.quantity} ${item.unit?.name ?? ''}',
                      style: context.textTheme.bodySmall,
                    )
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteItem(item),
              ),
            );
          },
        );
      },
    );
  }
}
