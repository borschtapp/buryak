import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_confirm.dart';
import '../../shared/components/empty_state.dart';
import '../../shared/components/icon_label.dart';
import '../../shared/components/recipes/recipes_grid.dart';
import '../../shared/layouts/app_list_scaffold.dart';
import '../../shared/models/collection.dart';
import '../../shared/models/recipe.dart';
import '../../shared/models/recipe_filter.dart';
import '../../shared/providers/saved.dart';
import '../../shared/repositories/collection_repository.dart';
import '../../shared/route_names.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';

enum _CollectionAction { delete }

class SavedTabs extends ConsumerWidget {
  final AsyncValue<List<Recipe>> value;
  final RecipeFilter? filter;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final RefreshCallback onRefresh;

  const SavedTabs({
    super.key,
    required this.value,
    this.filter,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
    required this.onRefresh,
  });

  bool get _isFilterEmpty => filter?.isEmpty ?? true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppListScaffold<List<Recipe>>(
      value: value,
      onRefresh: onRefresh,
      onLoadMore: onLoadMore,
      isLoadingMore: isLoadingMore,
      hasMore: hasMore,
      isEmpty: (recipes) => recipes.isEmpty,
      emptyState: EmptyState(
        icon: Icons.menu_book_outlined,
        title: _isFilterEmpty ? 'No recipes yet.' : 'No results',
        subtitle: _isFilterEmpty ? null : 'Try adjusting your search or filters.',
        action: _isFilterEmpty
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
                label: Text(context.l10n.feedClearFilters),
              ),
      ),
      data: (recipes) => RecipesGrid(
        recipes,
        onLoadMore: onLoadMore,
        isLoadingMore: isLoadingMore,
        hasMore: hasMore,
      ),
    );
  }
}

class SavedCookbooksTab extends ConsumerWidget {
  final AsyncValue<List<Collection>> value;
  final VoidCallback onCreateCollection;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final RefreshCallback onRefresh;

  const SavedCookbooksTab({
    super.key,
    required this.value,
    required this.onCreateCollection,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppListScaffold<List<Collection>>(
      value: value,
      onRefresh: onRefresh,
      onLoadMore: onLoadMore,
      isLoadingMore: isLoadingMore,
      hasMore: hasMore,
      isEmpty: (data) => data.isEmpty,
      emptyState: EmptyState(
        icon: Icons.collections_bookmark_outlined,
        title: 'No cookbooks yet.',
        action: TextButton.icon(
          onPressed: () => ref.invalidate(savedCollectionsProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ),
      data: (data) => GridView.builder(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 16 / 9,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final collection = data[index];
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
                    child: PopupMenuButton<_CollectionAction>(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      tooltip: 'More options',
                      onSelected: (value) async {
                        if (value == _CollectionAction.delete) {
                          final confirmed = await showConfirmDialog(
                            context,
                            title: 'Delete Cookbook?',
                            content: 'Are you sure you want to delete "${collection.name}"?',
                            confirmLabel: 'Delete',
                            destructive: true,
                          );

                          if (confirmed) {
                            try {
                              await ref.read(collectionRepositoryProvider).delete(collection.id);
                              HapticFeedback.mediumImpact();
                              ref.invalidate(savedCollectionsProvider);
                            } catch (e) {
                              ref.handleException(e);
                            }
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: _CollectionAction.delete,
                          child: IconLabel(
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            color: Colors.red,
                            iconSize: 24,
                            spacing: 8,
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
