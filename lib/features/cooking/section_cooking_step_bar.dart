import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';

class CookingStepBar extends HookWidget {
  const CookingStepBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onStepTapped,
    this.onPrevious,
    this.onNext,
  });

  final int currentStep;

  /// Total number of pages (ingredients + N instructions + completion).
  final int totalSteps;
  final ValueChanged<int> onStepTapped;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();

    // Auto-scroll so the active indicator stays visible.
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        final maxExtent = scrollController.position.maxScrollExtent;
        if (maxExtent <= 0) return;
        const itemWidth = 54.0; // 48 indicator + 6 spacing
        final target = (currentStep * itemWidth) - (scrollController.position.viewportDimension / 2) + (itemWidth / 2);
        scrollController.animateTo(
          target.clamp(0, maxExtent),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      });
      return null;
    }, [currentStep]);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingSmall, horizontal: 4),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevious,
              tooltip: context.l10n.cookingPreviousStep,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(totalSteps, (i) {
                    final isActive = i == currentStep;
                    final color = isActive ? context.colors.onPrimaryContainer : context.colors.onSurfaceVariant;
                    final Widget child;

                    if (i == 0) {
                      child = Icon(Icons.shopping_basket_outlined, size: 18, color: color);
                    } else if (i == totalSteps - 1) {
                      child = Icon(Icons.restaurant_outlined, size: 18, color: color);
                    } else {
                      child = Text(
                        '$i',
                        style: context.textTheme.labelLarge?.copyWith(
                          color: color,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _StepIndicator(
                        isActive: isActive,
                        onTap: () => onStepTapped(i),
                        child: child,
                      ),
                    );
                  }),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNext,
              tooltip: context.l10n.cookingNextStep,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.isActive,
    required this.onTap,
    required this.child,
  });

  final bool isActive;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? context.colors.primaryContainer : context.colors.surfaceContainerHighest,
          borderRadius: context.shapeMedium,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
