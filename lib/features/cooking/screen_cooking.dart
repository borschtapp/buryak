import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../shared/models/recipe.dart';
import '../../shared/route_names.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'section_cooking_complete.dart';
import 'section_cooking_ingredients.dart';
import 'section_cooking_step.dart';
import 'section_cooking_step_bar.dart';

class CookingScreen extends HookWidget {
  const CookingScreen({super.key, required this.recipe});

  final Recipe recipe;

  static const _pageAnimDuration = Duration(milliseconds: 300);
  static const _pageAnimCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final instructions = useMemoized(
      () => [...(recipe.instructions ?? [])]..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0)),
      [recipe.instructions],
    );
    final totalPages = instructions.length + 2; // ingredients + steps + complete

    final pageController = usePageController();
    final currentStep = useState(0);
    final scale = useState(1.0);

    // Keep screen awake during cooking
    useEffect(() {
      WakelockPlus.enable();
      return WakelockPlus.disable;
    }, const []);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _CookingTopBar(recipe: recipe),
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (i) => currentStep.value = i,
                children: [
                  CookingIngredientsPage(recipe: recipe, scale: scale.value, onScaleChanged: (s) => scale.value = s),
                  for (final instruction in instructions) CookingStepPage(instruction: instruction),
                  CookingCompletePage(
                    recipe: recipe,
                    onDone: () {
                      final messenger = ScaffoldMessenger.of(context);
                      context.pop();
                      messenger.showSnackBar(
                        SnackBar(content: Text(context.l10n.cookingEnjoyMeal)),
                      );
                    },
                  ),
                ],
              ),
            ),
            CookingStepBar(
              currentStep: currentStep.value,
              totalSteps: totalPages,
              onStepTapped: (i) => pageController.animateToPage(
                i,
                duration: _pageAnimDuration,
                curve: _pageAnimCurve,
              ),
              onPrevious: currentStep.value > 0
                  ? () => pageController.previousPage(
                      duration: _pageAnimDuration,
                      curve: _pageAnimCurve,
                    )
                  : null,
              onNext: currentStep.value < totalPages - 1
                  ? () => pageController.nextPage(
                      duration: _pageAnimDuration,
                      curve: _pageAnimCurve,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CookingTopBar extends StatelessWidget {
  const _CookingTopBar({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: UIConstants.paddingSmall,
      ),
      child: Row(
        children: [
          if (recipe.imageUrl case final imageUrl?) ...[
            ClipRRect(
              borderRadius: context.shapeSmall,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 40,
                  height: 40,
                  color: context.colors.surfaceContainerHighest,
                ),
                errorWidget: (_, _, _) => const SizedBox(width: 40, height: 40),
              ),
            ),
            const SizedBox(width: 12),
          ],

          Expanded(
            child: Text(
              recipe.name,
              style: context.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          IconButton(
            icon: const Icon(Icons.close),
            tooltip: context.l10n.cookingExitTooltip,
            onPressed: () => context.popOrGoNamed(RouteNames.feed),
          ),
        ],
      ),
    );
  }
}
