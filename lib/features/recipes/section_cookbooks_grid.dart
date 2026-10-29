import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_confirm.dart';
import '../../shared/components/empty_state.dart';
import '../../shared/components/icon_label.dart';
import '../../shared/components/recipes/collection_cover.dart';
import '../../shared/layouts/app_list_scaffold.dart';
import '../../shared/layouts/content_frame.dart';
import '../../shared/models/collection.dart';
import '../../shared/providers/saved.dart';
import '../../shared/route_names.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';

enum _CollectionAction { delete }

class CookbooksGrid extends ConsumerWidget {
  const CookbooksGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(savedCollectionsProvider.notifier);
    return AppListScaffold<List<Collection>>(
      value: ref.watch(savedCollectionsProvider),
      maxWidth: double.infinity,
      onRefresh: () async => ref.invalidate(savedCollectionsProvider),
      onLoadMore: notifier.loadMore,
      isLoadingMore: notifier.isLoadingMore,
      hasMore: notifier.hasMore,
      isEmpty: (data) => data.isEmpty,
      emptyState: EmptyState(
        icon: Icons.collections_bookmark_outlined,
        title: context.l10n.recipesNoCookbooksYet,
        action: TextButton.icon(
          onPressed: () => ref.invalidate(savedCollectionsProvider),
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.refresh),
        ),
      ),
      data: (data) => LayoutBuilder(
        builder: (context, constraints) => GridView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: ContentFrame.gutter(constraints.maxWidth) + UIConstants.paddingMedium,
            vertical: UIConstants.paddingMedium,
          ),
          // 360 keeps it to 4 columns at the full content width.
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 360,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 16 / 9,
          ),
          itemCount: data.length,
          itemBuilder: (context, index) => _CollectionCard(collection: data[index]),
        ),
      ),
    );
  }
}

class _CollectionCard extends ConsumerWidget {
  final Collection collection;

  const _CollectionCard({required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              child: CollectionCover(
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
                    context.l10n.recipesRecipesCount(collection.totalRecipes ?? 0),
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
                tooltip: context.l10n.recipesMoreOptionsTooltip,
                onSelected: (value) async {
                  if (value == _CollectionAction.delete) {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: context.l10n.recipesDeleteCookbookTitle,
                      content: context.l10n.recipesDeleteCookbookContent(collection.name),
                      confirmLabel: context.l10n.delete,
                      destructive: true,
                    );

                    if (confirmed && context.mounted) {
                      final deleted = await deleteCollectionMutation.tryRun(
                        ref,
                        (tsx) => tsx.get(savedCollectionsProvider.notifier).delete(collection.id),
                      );
                      if (deleted) {
                        HapticFeedback.mediumImpact();
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _CollectionAction.delete,
                    child: IconLabel(
                      icon: Icons.delete_outline,
                      label: context.l10n.delete,
                      color: context.colors.error,
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
  }
}
