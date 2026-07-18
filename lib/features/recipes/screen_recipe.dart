import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/standard_async_builder.dart';
import '../../shared/models/recipe.dart';
import '../../shared/route_names.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import '../planner/dialog_edit_plan.dart';
import '../shopping/dialog_add_from_recipe.dart';
import 'controller_recipe.dart';
import 'section_recipe_desktop.dart';
import 'section_recipe_mobile.dart';

class RecipeScreen extends ConsumerWidget {
  const RecipeScreen({
    super.key,
    required this.recipeId,
    this.initialRecipe,
    this.backFallback,
  });

  final String recipeId;
  final Recipe? initialRecipe;
  final String? backFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeControllerProvider(recipeId));

    return StandardAsyncBuilder<Recipe>(
      value: recipeAsync,
      onRetry: () => ref.invalidate(recipeControllerProvider(recipeId)),
      loading: () => initialRecipe != null
          ? _buildContent(context, initialRecipe!, isLoading: true)
          : const Center(child: CircularProgressIndicator()),
      data: (recipe) => _buildContent(context, recipe, isLoading: false),
    );
  }

  Widget _buildContent(BuildContext context, Recipe recipe, {required bool isLoading}) {
    return Material(
      color: context.colors.surface,
      child: Column(
        children: [
          Expanded(
            child: context.isMobile
                ? RecipeMobileSection(recipe: recipe, backFallback: backFallback)
                : RecipeDesktopSection(recipe: recipe),
          ),
          if (context.isMobile) ...[
            if (isLoading) const LinearProgressIndicator(minHeight: 2) else _MobileBottomActionBar(recipe: recipe),
          ],
        ],
      ),
    );
  }
}

class _MobileBottomActionBar extends StatelessWidget {
  final Recipe recipe;

  const _MobileBottomActionBar({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(color: context.colors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: recipe.hasCookableInstructions
                  ? () => context.pushNamed(
                      RouteNames.cooking,
                      pathParameters: {'rid': recipe.id},
                      extra: recipe,
                    )
                  : null,
              icon: const Icon(Icons.local_fire_department, size: 18),
              label: Text(context.l10n.recipeCook),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
              ),
            ),
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Expanded(
            child: OutlinedButton(
              onPressed: () => PlanBottomSheet.show(context, recipe: recipe),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
                side: BorderSide(color: context.colors.primary),
              ),
              child: Text(context.l10n.recipePlan),
            ),
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Expanded(
            child: OutlinedButton(
              onPressed: () => ShoppingBottomSheet.show(context, recipe),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
                side: BorderSide(color: context.colors.primary),
              ),
              child: Text(context.l10n.recipeShop),
            ),
          ),
        ],
      ),
    );
  }
}
