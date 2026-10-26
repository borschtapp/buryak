import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../shared/components/icon_label.dart';
import '../../shared/components/loading_indicator.dart';
import '../../shared/components/recipes/dialog_select_collections.dart';
import '../../shared/components/recipes/liked_by_avatars.dart';
import '../../shared/providers/saved.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import 'controller_recipe.dart';

enum _RecipeMenuAction { openInBrowser, share, refresh }

class RecipeActions extends ConsumerWidget {
  final String recipeId;

  const RecipeActions({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = ref.watch(recipeControllerProvider(recipeId)).value;
    final isSaved = recipe != null && ref.watchIsSaved(recipe);
    final isCollected = recipe?.collections?.isNotEmpty ?? false;
    final l10n = context.l10n;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (recipe != null) LikedByAvatars(users: ref.watchLikedByOthers(recipe), ringColor: context.colors.surface),
        IconButton(
          visualDensity: .compact,
          icon: Icon(isSaved ? Icons.favorite : Icons.favorite_outline),
          tooltip: isSaved ? l10n.recipeDislikeTooltip : l10n.recipeLikeTooltip,
          onPressed: recipe == null
              ? null
              : () async {
                  try {
                    await ref.read(recipeSaveTogglesProvider.notifier).toggle(recipeId, isSaved: isSaved);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.l10n.recipeLikeFailed)),
                      );
                    }
                  }
                },
        ),
        IconButton(
          visualDensity: .compact,
          icon: Icon(isCollected ? Icons.collections_bookmark : Icons.bookmark_add_outlined),
          tooltip: isCollected ? l10n.recipeUnsaveTooltip : l10n.recipeSaveTooltip,
          onPressed: recipe == null
              ? null
              : () async {
                  final updated = await showCollectionsBottomSheet(
                    context,
                    ref,
                    recipeId: recipeId,
                    initialCollections: recipe.collections,
                  );
                  if (updated != null) {
                    ref.read(recipeControllerProvider(recipeId).notifier).updateCollections(updated);
                  }
                },
        ),
        // Every entry so far acts on the source page.
        if (recipe?.sourceUrl case final sourceUrl?) _RecipeMenu(recipeId: recipeId, sourceUrl: sourceUrl),
      ],
    );
  }
}

class _RecipeMenu extends ConsumerWidget {
  final String recipeId;
  final String sourceUrl;

  const _RecipeMenu({required this.recipeId, required this.sourceUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refresh = refreshRecipeMutation(recipeId);
    final isRefreshing = ref.watch(refresh).isPending;
    final l10n = context.l10n;

    Future<void> openInBrowser() async {
      try {
        final opened = await launchUrlString(sourceUrl, mode: .externalApplication);
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.authorSourceLinkError)));
        }
      } catch (e) {
        ref.handleException(e);
      }
    }

    Future<void> refreshFromSource() async {
      final refreshed = await refresh.tryRun(
        ref,
        (tsx) => tsx.get(recipeControllerProvider(recipeId).notifier).refreshFromSource(),
      );
      if (refreshed && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.recipeRefreshed)));
      }
    }

    return PopupMenuButton<_RecipeMenuAction>(
      enabled: !isRefreshing,
      style: IconButton.styleFrom(visualDensity: .compact),
      // Inherits the app bar's foreground, so it stays legible over the hero image.
      icon: isRefreshing ? LoadingIndicator(color: IconTheme.of(context).color) : const Icon(Icons.more_vert),
      tooltip: l10n.recipesMoreOptionsTooltip,
      onSelected: (action) => switch (action) {
        .openInBrowser => openInBrowser(),
        .share => SharePlus.instance.share(ShareParams(uri: Uri.parse(sourceUrl))),
        .refresh => refreshFromSource(),
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: .share,
          child: IconLabel(icon: Icons.share, label: l10n.recipeShareTooltip, iconSize: 24, spacing: 8),
        ),
        PopupMenuItem(
          value: .openInBrowser,
          child: IconLabel(icon: Icons.open_in_browser, label: l10n.recipeOpenInBrowser, iconSize: 24, spacing: 8),
        ),
        PopupMenuItem(
          value: .refresh,
          child: IconLabel(icon: Icons.refresh, label: l10n.recipeRefreshFromSource, iconSize: 24, spacing: 8),
        ),
      ],
    );
  }
}
