import 'package:flutter/material.dart';

import '../../shared/extensions.dart';
import '../../shared/models/shopping_item.dart';
import '../../shared/models/shopping_list.dart';
import '../../shared/repositories/shopping_list_repository.dart';
import '../../shared/views/async_loader.dart';
import '../../shared/views/root_layout.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  late Future<(ShoppingList, List<ShoppingItem>)> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<(ShoppingList, List<ShoppingItem>)> _loadData() async {
    final lists = await ShoppingListRepository.findAll();
    final list = lists.firstWhere((l) => l.isDefault ?? false, orElse: () => lists.first);
    final items = await ShoppingListRepository.findItems(list.id);
    _sortItems(items);
    return (list, items);
  }

  void _sortItems(List<ShoppingItem> items) {
    items.sort((a, b) {
      if (a.isBought == b.isBought) return 0;
      if (a.isBought ?? false) return 1;
      return -1;
    });
  }

  Future<void> _toggleItem(int index, ShoppingItem item, String listId, List<ShoppingItem> items) async {
    final newValue = !(item.isBought ?? false);
    setState(() {
      items[index] = ShoppingItem(
        id: item.id,
        shoppingListId: item.shoppingListId,
        isBought: newValue,
        text: item.text,
        amount: item.amount,
        food: item.food,
        foodId: item.foodId,
        unit: item.unit,
        unitId: item.unitId,
      );
      _sortItems(items);
    });

    try {
      await ShoppingListRepository.updateItem(listId, item.id, isBought: newValue);
    } catch (e) {
      if (mounted) {
        setState(() {
          final resetIndex = items.indexWhere((i) => i.id == item.id);
          if (resetIndex != -1) {
            items[resetIndex] = item;
            _sortItems(items);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update item.')),
        );
      }
    }
  }

  Future<void> _deleteItem(int index, ShoppingItem item, String listId, List<ShoppingItem> items) async {
    setState(() {
      items.removeAt(index);
    });

    try {
      await ShoppingListRepository.deleteItem(listId, item.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          items.insert(index, item);
          _sortItems(items);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete item.')),
        );
      }
    }
  }

  Future<void> _showAddItemDialog(String listId, List<ShoppingItem> items) async {
    if (!mounted) return;

    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Item Name', hintText: 'e.g. Milk'),
          onSubmitted: (val) => Navigator.pop(context, val),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add')),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      try {
        final newItem = await ShoppingListRepository.createItem(listId, text: name.trim());
        if (mounted) {
          setState(() {
            items.insert(0, newItem);
            _sortItems(items);
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add item.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<(ShoppingList, List<ShoppingItem>)>(
      future: _dataFuture,
      builder: (context, data) {
        final (list, items) = data;
        return RootLayout(
          currentIndex: 3,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddItemDialog(list.id, items),
            child: const Icon(Icons.add),
          ),
          child: items.isEmpty
              ? const Center(child: Text('Your shopping list is empty.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (context, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final label = item.food?.name ?? item.text ?? '';
                    return ListTile(
                      leading: Checkbox(
                        value: item.isBought ?? false,
                        onChanged: (_) => _toggleItem(index, item, list.id, items),
                      ),
                      title: Text(
                        label,
                        style: (item.isBought ?? false)
                            ? context.textTheme.bodyMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      subtitle: item.amount != null
                          ? Text(
                              '${item.amount} ${item.unit?.name ?? ''}',
                              style: context.textTheme.bodySmall,
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteItem(index, item, list.id, items),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
