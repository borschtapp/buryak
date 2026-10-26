import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/layouts/content_frame.dart';
import '../../shared/models/collection.dart';
import '../../shared/providers/saved.dart';
import '../../shared/route_names.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import '../../shared/components/recipes/collection_cover.dart';

class SavedCookbooksCarousel extends ConsumerWidget {
  final VoidCallback onCreateCookbook;
  final VoidCallback onSeeAll;

  const SavedCookbooksCarousel({
    super.key,
    required this.onCreateCookbook,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(savedCollectionsProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = ContentFrame.gutter(constraints.maxWidth);
        final horizontalInset = gutter + UIConstants.paddingMedium;

        // The cookbooks and a "+ New Cookbook" card, or skeletons while [items] load.
        // Mouse drag is enabled so the row can be scrolled on web/desktop without
        // Shift+wheel or a trackpad.
        final scrollBehavior = ScrollConfiguration.of(context);
        Widget buildList(List<Collection>? items) => ScrollConfiguration(
          behavior: scrollBehavior.copyWith(
            dragDevices: {...scrollBehavior.dragDevices, PointerDeviceKind.mouse},
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalInset, vertical: 4),
            itemCount: items == null ? 3 : items.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => switch (items) {
              null => const _CookbookCarouselSkeleton(),
              _ when index == items.length => _CreateCookbookCard(onTap: onCreateCookbook),
              _ => _CookbookCarouselCard(collection: items[index]),
            },
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(horizontalInset, 8, horizontalInset, 4),
              child: Row(
                children: [
                  Text(
                    context.l10n.savedTabCookbooks,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onSeeAll,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(context.l10n.seeAll),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 96,
              child: collections.when(
                data: buildList,
                loading: () => buildList(null),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CookbookCarouselCard extends StatelessWidget {
  final Collection collection;

  const _CookbookCarouselCard({required this.collection});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: context.colors.surfaceContainerLow,
      shape: RoundedSuperellipseBorder(borderRadius: context.shapeLarge),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            RouteNames.collection,
            pathParameters: {'cid': collection.id},
          );
        },
        child: SizedBox(
          width: 210,
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.paddingSmall),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: ClipRRect(
                    borderRadius: context.shapeMedium,
                    child: CollectionCover(collection: collection),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        collection.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.recipesRecipesCount(collection.totalRecipes ?? 0),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateCookbookCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateCookbookCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: context.colors.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedSuperellipseBorder(
        borderRadius: context.shapeLarge,
        side: BorderSide(
          color: context.colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 160,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 20,
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.cookbookCreateTitle,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CookbookCarouselSkeleton extends StatelessWidget {
  const _CookbookCarouselSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: context.colors.surfaceContainerLow,
      shape: RoundedSuperellipseBorder(borderRadius: context.shapeLarge),
      child: const SizedBox(
        width: 200,
        height: 88,
      ),
    );
  }
}
