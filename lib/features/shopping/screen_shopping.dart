import 'package:flutter/material.dart';

import '../../shared/extensions.dart';
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
  late Future<List<ShoppingList>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = ShoppingListRepository.findAll().then((list) {
      _sortItems(list);
      return list;
    });
  }

  void _sortItems(List<ShoppingList> items) {
    items.sort((a, b) {
      if (a.isBought == b.isBought) return 0;
      if (a.isBought ?? false) return 1;
      return -1;
    });
  }

  Future<void> _toggleItem(int index, ShoppingList item, List<ShoppingList> items) async {
    final newValue = !(item.isBought ?? false);
    setState(() {
      items[index] = ShoppingList(
        id: item.id,
        householdId: item.householdId,
        isBought: newValue,
        product: item.product,
        quantity: item.quantity,
        unit: item.unit,
        unitId: item.unitId,
      );
      _sortItems(items);
    });

    try {
      await ShoppingListRepository.update(
        item.id,
        isBought: newValue,
      );
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

  Future<void> _deleteItem(int index, ShoppingList item, List<ShoppingList> items) async {
    setState(() {
      items.removeAt(index);
    });

    try {
      await ShoppingListRepository.delete(item.id);
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

  Future<void> _showAddItemDialog() async {
    final items = await _itemsFuture;
    if (!mounted) return;
    
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Product Name', hintText: 'e.g. Milk'),
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
        final newItem = await ShoppingListRepository.create(name.trim());
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
    return RootLayout(
      currentIndex: 3,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
      child: AsyncLoader<List<ShoppingList>>(
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
                  onChanged: (_) => _toggleItem(index, item, items),
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
                  onPressed: () => _deleteItem(index, item, items),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
