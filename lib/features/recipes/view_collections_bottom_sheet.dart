import 'package:flutter/material.dart';

import '../../shared/repositories/collection_repository.dart';
import '../../shared/models/collection.dart';

void showCollectionsBottomSheet(
  BuildContext context, {
  required String recipeId,
  List<Collection>? initialCollections,
}) {
  assert(recipeId.isNotEmpty, 'recipeId must not be empty');

  final future = CollectionRepository.findAll(preload: 'recipes:5,recipes.images,total_recipes');

  showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return FutureBuilder<List<Collection>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return SizedBox(height: 200, child: Center(child: Text('Error: ${snapshot.error}')));
          }
          final collections = snapshot.data ?? [];
          if (collections.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(child: Text('No cookbooks found. Create one in Profile.')),
            );
          }

          final Set<String> localAddedId = {};
          final Set<String> localRemovedId = {};

          return StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Add to Cookbook', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Flexible(
                      child: ListView.builder(
                        itemCount: collections.length,
                        itemBuilder: (context, index) {
                          final collection = collections[index];
                          final originallyInCollection = initialCollections?.any((c) => c.id == collection.id) ?? false;

                          final isInCollection = originallyInCollection
                              ? !localRemovedId.contains(collection.id)
                              : localAddedId.contains(collection.id);

                          return ListTile(
                            leading: Icon(
                              isInCollection ? Icons.check_circle : Icons.add_circle_outline,
                              color: isInCollection ? Colors.green : null,
                            ),
                            title: Text(collection.name),
                            onTap: () async {
                              try {
                                if (isInCollection) {
                                  await CollectionRepository.removeRecipe(collection.id, recipeId);
                                  setSheetState(() {
                                    if (originallyInCollection) {
                                      localRemovedId.add(collection.id);
                                    } else {
                                      localAddedId.remove(collection.id);
                                    }
                                  });
                                } else {
                                  await CollectionRepository.addRecipe(collection.id, recipeId);
                                  setSheetState(() {
                                    if (originallyInCollection) {
                                      localRemovedId.remove(collection.id);
                                    } else {
                                      localAddedId.add(collection.id);
                                    }
                                  });
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
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
        },
      );
    },
  );
}
