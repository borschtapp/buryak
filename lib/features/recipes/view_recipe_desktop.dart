import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../shared/components/recipes/author_line.dart';
import '../../shared/components/recipes/hero_image.dart';
import '../../shared/components/recipes/ingredients.dart';
import '../../shared/components/recipes/instructions.dart';
import '../../shared/components/recipes/meta_row.dart';
import '../../shared/components/recipes/scale_control.dart';
import '../../shared/layouts/content_frame.dart';
import '../../shared/models/recipe.dart';
import '../../shared/route_names.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import '../planner/dialog_edit_plan.dart';
import '../shopping/dialog_add_from_recipe.dart';
import 'section_recipe_actions.dart';

class RecipeDesktopView extends HookWidget {
  const RecipeDesktopView({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final scale = useState(1.0);
    return ContentFrame(
      maxWidth: 1280,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeHeroImage(
              recipe: recipe,
              height: UIConstants.recipeMaxImageHeightDesktop,
              borderRadius: BorderRadius.circular(16),
            ),
            const SizedBox(height: 32),
            // Row 3: main action buttons centered
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (recipe.hasCookableInstructions) ...[
                  FilledButton.icon(
                    onPressed: () {
                      if (!context.mounted) return;
                      context.pushNamed(
                        RouteNames.cooking,
                        pathParameters: {'rid': recipe.id},
                        extra: recipe,
                      );
                    },
                    icon: const Icon(Icons.local_fire_department, size: 18),
                    label: const Text('Start Cooking'),
                  ),
                  const SizedBox(width: UIConstants.paddingSmall),
                ],
                OutlinedButton.icon(
                  onPressed: () => _showPlanSheet(context),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('Plan'),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                OutlinedButton.icon(
                  onPressed: () => _showShoppingSheet(context, recipe),
                  icon: const Icon(Icons.shopping_basket, size: 18),
                  label: const Text('Shop'),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            // Row 1: full-width title
            Text(
              recipe.name,
              style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Row 2: publisher (left) + published date (right)
            Row(
              children: [
                RecipeAuthorLine(recipe: recipe, showPrefix: false, useUnderline: false),
                const Spacer(),
                if (recipe.published != null)
                  Text(
                    'Published: ${DateFormat.yMMMd().format(recipe.published!)}',
                    style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            // Row 4: meta items (left) + icon actions (right)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: RecipeMetaRow(recipe: recipe)),
                RecipeActions(recipeId: recipe.id),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ContentSection(
                    title: 'Ingredients',
                    trailing: ScaleControl(
                      recipe: recipe,
                      initialScale: scale.value,
                      onScaleChanged: (s) => scale.value = s,
                    ),
                    child: Ingredients(
                      recipe.ingredients ?? [],
                      equipment: recipe.equipment,
                      scale: scale.value,
                      showHeader: false,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  child: _ContentSection(
                    title: 'Preparation',
                    child: Instructions(recipe.instructions ?? []),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShoppingSheet(BuildContext context, Recipe recipe) {
    if (!context.mounted) return;
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
        snapSizes: maxFraction > 0.55 ? [maxFraction * 0.5] : null,
        shouldCloseOnMinExtent: true,
        builder: (context, scrollController) => ShoppingBottomSheet(
          recipe: recipe,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showPlanSheet(BuildContext context) {
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PlanBottomSheet(recipe: recipe),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: context.textTheme.headlineSmall),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
        const SizedBox(height: UIConstants.paddingMedium),
        child,
      ],
    );
  }
}
