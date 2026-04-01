import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/empty_state.dart';
import '../../shared/models/collection.dart';
import '../../shared/models/recipe.dart';
import '../../shared/models/recipe_filter.dart';
import '../../shared/providers/saved.dart';
import '../../shared/repositories/collection_repository.dart';
import '../../shared/route_names.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import 'section_recipes_grid.dart';

class SavedTabs extends ConsumerWidget {
  final List<Recipe> recipes;
  final RecipeFilter? filter;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  const SavedTabs({
    super.key,
    required this.recipes,
    this.filter,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (recipes.isEmpty) {
      final isEmpty = filter?.isEmpty ?? true;
      return EmptyState(
        icon: Icons.menu_book_outlined,
        title: isEmpty ? 'No recipes yet.' : 'No results',
        subtitle: isEmpty ? null : 'Try adjusting your search or filters.',
        action: isEmpty
            ? TextButton.icon(
                onPressed: () => ref.invalidate(savedRecipesProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              )
            : TextButton.icon(
                onPressed: () {
                  ref.read(savedRecipesFilterProvider.notifier).update(const RecipeFilter());
                  ref.invalidate(savedRecipesProvider);
                },
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Clear filters'),
              ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(savedRecipesProvider),
      child: RecipesGrid(
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
            ? EmptyState(
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
                                context.pushNamed(
                                  RouteNames.collection,
                                  pathParameters: {'cid': collection.id},
                                );
                              },
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: _CollectionCover(
                                      collection: collection,
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          stops: const [0.4, 1.0],
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.85),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
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
                ref.handleException(e);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CollectionCover extends StatelessWidget {
  final Collection collection;

  const _CollectionCover({required this.collection});

  @override
  Widget build(BuildContext context) {
    final images = (collection.recipes ?? []).map((r) => r.imageUrl).whereType<String>().take(3).toList();

    if (images.isEmpty) {
      return Container(
        color: context.colors.surfaceContainerHighest,
        child: Icon(Icons.collections, size: 48, color: context.colors.onSurfaceVariant),
      );
    }

    if (images.length == 1) {
      return _coverImage(images[0]);
    }

    if (images.length == 2) {
      return Row(
        children: [
          Expanded(child: _coverImage(images[0])),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _coverImage(images[1])),
        ],
      );
    }

    // 3 images: left half + right half split into top/bottom
    return Row(
      children: [
        Expanded(child: _coverImage(images[0])),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: Column(
            children: [
              Expanded(child: _coverImage(images[1])),
              const Divider(height: 1, thickness: 1),
              Expanded(child: _coverImage(images[2])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _coverImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorWidget: (_, _, _) => const ColoredBox(color: Color(0xFF9E9E9E)),
    );
  }
}
