import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/hooks.dart';
import 'dialog_create_collection.dart';
import 'section_cookbooks_grid.dart';

class CookbooksScreen extends HookConsumerWidget {
  const CookbooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fab = useMemoized(
      () => FloatingActionButton(
        heroTag: 'cookbooks_create_fab',
        onPressed: () => showCreateCollectionDialog(context),
        child: const Icon(Icons.add),
      ),
    );

    useFab(ref, fab);

    return const CookbooksGrid();
  }
}
