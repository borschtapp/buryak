import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/models/collection.dart';
import '../../shared/repositories/collection_repository.dart';
import 'notifier_saved.dart';
import 'screen_collection.dart';

void showCollectionsBottomSheet(
  BuildContext context,
  WidgetRef ref, {
  required String recipeId,
  List<Collection>? initialCollections,
}) {
  if (recipeId.isEmpty) {
    debugPrint('showCollectionsBottomSheet called with empty recipeId');
    return;
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => _CollectionsBottomSheetContent(
        recipeId: recipeId,
        initialCollections: initialCollections,
        scrollController: scrollController,
      ),
    ),
  );
}

class _CollectionsBottomSheetContent extends HookConsumerWidget {
  final String recipeId;
  final List<Collection>? initialCollections;
  final ScrollController scrollController;

  const _CollectionsBottomSheetContent({
    required this.recipeId,
    required this.initialCollections,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localAddedIds = useState<Set<String>>({});
    final localRemovedIds = useState<Set<String>>({});
    final isSaving = useState(false);
    final collectionsAsync = ref.watch(savedCollectionsProvider);

    return collectionsAsync.when(
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (Object err, _) => SizedBox(height: 200, child: Center(child: Text('Error: $err'))),
      data: (List<Collection> collections) {
        if (collections.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No cookbooks found. Create one in Saved.')),
          );
        }

        final initialCollectionIds = initialCollections?.map((c) => c.id).toSet() ?? <String>{};

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add to Cookbook', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (localAddedIds.value.isNotEmpty || localRemovedIds.value.isNotEmpty)
                      isSaving.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TextButton(
                              onPressed: () async {
                                isSaving.value = true;
                                try {
                                  final repo = ref.read(collectionRepositoryProvider);

                                  final futures = [
                                    ...localAddedIds.value.map((id) => repo.addRecipe(id, recipeId)),
                                    ...localRemovedIds.value.map((id) => repo.removeRecipe(id, recipeId)),
                                  ];

                                  await Future.wait(futures);

                                  ref.invalidate(savedCollectionsProvider);
                                  ref.invalidate(collectionRecipesProvider);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Cookbooks updated')),
                                    );
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                } finally {
                                  isSaving.value = false;
                                }
                              },
                              child: const Text('Save'),
                            ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    final originallyInCollection = initialCollectionIds.contains(collection.id);

                    final isInCollection = originallyInCollection
                        ? !localRemovedIds.value.contains(collection.id)
                        : localAddedIds.value.contains(collection.id);

                    return ListTile(
                      leading: Icon(
                        isInCollection ? Icons.check_box : Icons.check_box_outline_blank,
                        color: isInCollection ? Colors.green : null,
                      ),
                      title: Text(collection.name),
                      trailing: isInCollection ? const Text('Selected', style: TextStyle(color: Colors.green, fontSize: 12)) : null,
                      onTap: isSaving.value
                          ? null
                          : () {
                              final action = isInCollection ? 'Removed from' : 'Added to';
                              SemanticsService.sendAnnouncement(
                                View.of(context),
                                '$action ${collection.name}',
                                TextDirection.ltr,
                              );
                              if (isInCollection) {
                                if (originallyInCollection) {
                                  localRemovedIds.value = {...localRemovedIds.value, collection.id};
                                } else {
                                  localAddedIds.value = localAddedIds.value.where((id) => id != collection.id).toSet();
                                }
                              } else {
                                if (originallyInCollection) {
                                  localRemovedIds.value = localRemovedIds.value.where((id) => id != collection.id).toSet();
                                } else {
                                  localAddedIds.value = {...localAddedIds.value, collection.id};
                                }
                              }
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
