import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/recipe.dart';
import '../../util/extensions.dart';

/// Renders a serving stepper (when [recipe.yield] is known) or a fixed-multiplier
/// segmented button (when yield is absent). Calls [onScaleChanged] with the
/// computed multiplier whenever the user adjusts the value.
class ScaleControl extends StatelessWidget {
  const ScaleControl({required this.recipe, required this.onScaleChanged, this.initialScale = 1.0, super.key});

  final Recipe recipe;
  final ValueChanged<double> onScaleChanged;
  final double initialScale;

  @override
  Widget build(BuildContext context) {
    if (recipe.yield != null) {
      return _YieldStepper(baseYield: recipe.yield!, onScaleChanged: onScaleChanged, initialScale: initialScale);
    }
    return _ScaleSelector(onChanged: onScaleChanged, initialScale: initialScale);
  }
}

class _YieldStepper extends HookWidget {
  const _YieldStepper({required this.baseYield, required this.onScaleChanged, required this.initialScale});

  final int baseYield;
  final ValueChanged<double> onScaleChanged;
  final double initialScale;

  @override
  Widget build(BuildContext context) {
    final servings = useState((baseYield * initialScale).round());

    // mainAxisSize.min is critical — this widget is placed as a non-flex child
    // inside a Row that already has a Spacer. Using max would crash layout.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: servings.value > 1
              ? () {
                  servings.value--;
                  onScaleChanged(servings.value / baseYield);
                }
              : null,
          visualDensity: VisualDensity.compact,
          tooltip: context.l10n.decreaseServings,
        ),
        SizedBox(
          width: 32,
          child: Text(
            '${servings.value}',
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            servings.value++;
            onScaleChanged(servings.value / baseYield);
          },
          visualDensity: VisualDensity.compact,
          tooltip: context.l10n.increaseServings,
        ),
      ],
    );
  }
}

class _ScaleSelector extends StatelessWidget {
  const _ScaleSelector({required this.onChanged, required this.initialScale});

  final ValueChanged<double> onChanged;
  final double initialScale;

  static const _options = [0.5, 1.0, 2.0];

  static String _label(double m) => '${m.displayAmount}×';

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<double>(
      segments: _options.map((m) => ButtonSegment<double>(value: m, label: Text(_label(m)))).toList(),
      selected: {initialScale},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
    );
  }
}
