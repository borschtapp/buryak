import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/collection.dart';
import '../../providers/saved.dart';
import '../../repositories/collection_repository.dart';
import '../../util/error_extensions.dart';
import '../../util/extensions.dart';
import '../loading_button.dart';
import '../standard_async_builder.dart';
import '../standard_bottom_sheet.dart';

Future<List<Collection>?> showCollectionsBottomSheet(
  BuildContext context,
  WidgetRef ref, {
  required String recipeId,
  List<Collection>? initialCollections,
}) {
  assert(recipeId.isNotEmpty, 'recipeId cannot be empty');

  return showModalBottomSheet<List<Collection>>(
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

    return StandardAsyncBuilder<List<Collection>>(
      value: collectionsAsync,
      onRetry: () => ref.invalidate(savedCollectionsProvider),
      data: (collections) {
        if (collections.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(child: Text('${context.l10n.recipesCookbookEmptyTitle}. ${context.l10n.recipesCookbookEmptySubtitle}')),
          );
        }

        final initialCollectionIds = initialCollections?.map((c) => c.id).toSet() ?? <String>{};

        final hasChanges = localAddedIds.value.isNotEmpty || localRemovedIds.value.isNotEmpty;

        return StandardBottomSheet(
          title: 'Add to Cookbook',
          padding: const EdgeInsets.symmetric(vertical: 16),
          actions: [
            if (hasChanges)
              LoadingButton(
                isLoading: isSaving.value,
                type: LoadingButtonType.text,
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

                    final updatedCollections = collections
                        .where(
                          (c) =>
                              (initialCollectionIds.contains(c.id) && !localRemovedIds.value.contains(c.id)) ||
                              localAddedIds.value.contains(c.id),
                        )
                        .toList();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.l10n.recipesCookbooksUpdated)),
                      );
                      Navigator.pop(context, updatedCollections);
                    }
                  } catch (e) {
                    ref.handleException(e);
                  } finally {
                    isSaving.value = false;
                  }
                },
                child: Text(context.l10n.save),
              ),
          ],
          child: Flexible(
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
                  trailing: isInCollection
                      ? Text(context.l10n.recipesCollectionSelected, style: const TextStyle(color: Colors.green, fontSize: 12))
                      : null,
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
        );
      },
    );
  }
}
