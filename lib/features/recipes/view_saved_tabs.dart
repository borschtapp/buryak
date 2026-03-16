import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/models/collection.dart';
import '../../shared/models/recipe.dart';
import '../../shared/extensions.dart';
import '../../shared/route_names.dart';
import '../../shared/repositories/collection_repository.dart';
import '../../shared/repositories/repository.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/recipes/view_recipes_grid.dart';
import 'notifier_saved.dart';

class SavedRecipesTab extends ConsumerWidget {
  final List<Recipe> recipes;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  const SavedRecipesTab({
    super.key,
    required this.recipes,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (recipes.isEmpty) {
      return EmptyStateView(
        icon: Icons.menu_book_outlined,
        title: 'No recipes yet.',
        action: TextButton.icon(
          onPressed: () => ref.invalidate(savedRecipesProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(savedRecipesProvider),
      child: RecipesGridView(
        recipes,
        onLoadMore: onLoadMore,
        isLoadingMore: isLoadingMore,
        hasMore: hasMore,
      ),
    );
  }
}

class SavedCookbooksTab extends ConsumerWidget {
  final List<Collection> collections;
  final VoidCallback onCreateCollection;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  const SavedCookbooksTab({
    super.key,
    required this.collections,
    required this.onCreateCollection,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(savedCollectionsProvider),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: collections.isEmpty
            ? EmptyStateView(
                icon: Icons.collections_bookmark_outlined,
                title: 'No cookbooks yet.',
                action: TextButton.icon(
                  onPressed: () => ref.invalidate(savedCollectionsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: NotificationListener<ScrollEndNotification>(
                      onNotification: (notification) {
                        if (hasMore && !isLoadingMore && notification.metrics.extentAfter < 300) {
                          onLoadMore?.call();
                        }
                        return false;
                      },
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 300,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 16 / 9,
                        ),
                        itemCount: collections.length,
                        itemBuilder: (context, index) {
                          final collection = collections[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                context.goNamed(
                                  RouteNames.collection,
                                  pathParameters: {'cid': collection.id},
                                );
                              },
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Container(
                                      color: context.colors.surfaceContainerHighest,
                                      child: Icon(Icons.collections, size: 48, color: context.colors.onSurfaceVariant),
                                    ),
                                  ),
                                  Positioned.fill(child: Container(color: context.colors.shadow.withValues(alpha: 0.1))),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          collection.name,
                                          style: context.textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${collection.totalRecipes ?? 0} recipes',
                                          style: context.textTheme.bodySmall?.copyWith(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                                      tooltip: 'More options',
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _confirmDelete(context, ref, collection);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Collection collection) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cookbook?'),
        content: Text('Are you sure you want to delete "${collection.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(collectionRepositoryProvider).delete(collection.id);
                HapticFeedback.mediumImpact();
                ref.invalidate(savedCollectionsProvider);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Failed to delete cookbook: ${e is GeneralApiException ? e.message : "Unexpected error"}')));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
