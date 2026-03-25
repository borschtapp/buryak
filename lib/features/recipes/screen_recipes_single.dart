import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/extensions.dart';
import '../../shared/models/recipe.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/views/view_plan_bottom_sheet.dart';
import 'controller_recipe.dart';
import 'view_recipe_desktop.dart';
import 'view_recipe_mobile.dart';
import 'view_shopping_bottom_sheet.dart';

class RecipeScreen extends ConsumerWidget {
  const RecipeScreen({
    super.key,
    required this.recipeId,
    this.initialRecipe,
  });

  final String recipeId;
  final Recipe? initialRecipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeControllerProvider(recipeId));

    return recipeAsync.when(
      data: (recipe) => _buildContent(context, recipe, isLoading: false),
      loading: () => initialRecipe != null
          ? _buildContent(context, initialRecipe!, isLoading: true)
          : const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ErrorView(
        message: err.toString(),
        onRetry: () => ref.invalidate(recipeControllerProvider(recipeId)),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Recipe recipe, {required bool isLoading}) {
    return Material(
      color: context.colors.surface,
      child: Column(
        children: [
          Expanded(
            child: context.isMobile ? RecipeMobileView(recipe: recipe) : RecipeDesktopView(recipe: recipe),
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
          top: BorderSide(color: context.colors.secondary.withValues(alpha: 50 / 255)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showShoppingSheet(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: context.colors.primary),
              ),
              child: const Text('Add to shopping'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: () => _showPlanSheet(context),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: context.colors.primaryContainer,
                foregroundColor: context.colors.onPrimaryContainer,
              ),
              child: const Text('Add to plan'),
            ),
          ),
        ],
      ),
    );
  }

  void _showShoppingSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddToShoppingBottomSheet(recipe: recipe),
    );
  }

  void _showPlanSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PlanBottomSheet(recipe: recipe),
    );
  }
}
