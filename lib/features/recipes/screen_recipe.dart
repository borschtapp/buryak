import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/standard_async_builder.dart';
import '../../shared/models/recipe.dart';
import '../../shared/route_names.dart';
import '../../shared/util/extensions.dart';
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
            child: context.isMobile ? RecipeMobileView(recipe: recipe, backFallback: backFallback) : RecipeDesktopView(recipe: recipe),
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
          top: BorderSide(color: context.colors.secondary.withValues(alpha: 0.2)),
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
              label: const Text('Cook'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showPlanSheet(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: context.colors.primary),
              ),
              child: const Text('Plan'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showShoppingSheet(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: context.colors.primary),
              ),
              child: const Text('Shop'),
            ),
          ),
        ],
      ),
    );
  }

  void _showShoppingSheet(BuildContext context) {
    final screenHeight = MediaQuery.heightOf(context);
    final topReserved = MediaQuery.paddingOf(context).top + kToolbarHeight;
    final maxFraction = (screenHeight - topReserved) / screenHeight;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.3,
        maxChildSize: maxFraction,
        expand: false,
        snap: true,
        snapSizes: maxFraction > 0.55 ? const [0.5] : null,
        shouldCloseOnMinExtent: true,
        builder: (context, scrollController) => ShoppingBottomSheet(
          recipe: recipe,
          scrollController: scrollController,
        ),
      ),
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
