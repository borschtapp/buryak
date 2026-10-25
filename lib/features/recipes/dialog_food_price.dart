import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/components/dialog_confirm.dart';
import '../../shared/components/dismissible_tile.dart';
import '../../shared/components/loading_button.dart';
import '../../shared/components/recipes/unit_picker_form_field.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/food.dart';
import '../../shared/models/food_price.dart';
import '../../shared/models/food_unit_conversion.dart';
import '../../shared/models/recipe_ingredient.dart';
import '../../shared/models/unit.dart';
import '../../shared/providers/food_catalog.dart';
import '../../shared/providers/household.dart';
import '../../shared/providers/recipe_price.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import '../../shared/util/validator.dart';
import 'dialog_food_conversion.dart';

class FoodPriceBottomSheet extends HookConsumerWidget {
  const FoodPriceBottomSheet({
    super.key,
    required this.food,
    this.ingredient,
  });

  final Food food;
  final RecipeIngredient? ingredient;

  static String _defaultAmount(double? recipeAmount) {
    if (recipeAmount == null || recipeAmount <= 1) return '1';
    if (recipeAmount >= 100) return '1000';
    return '100';
  }

  static void show(
    BuildContext context, {
    required Food food,
    RecipeIngredient? ingredient,
  }) {
    showAppBottomSheet<void>(
      context: context,
      builder: (_) => FoodPriceBottomSheet(food: food, ingredient: ingredient),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final priceController = useTextEditingController();
    final defaultAmount = useMemoized(() => _defaultAmount(ingredient?.amount), [ingredient?.amount]);
    final amountController = useTextEditingController(text: defaultAmount);
    final isSaving = ref.watch(recordPriceMutation).isPending;

    final pricesAsync = ref.watch(foodPricesProvider(food.id));
    final unitsAsync = ref.watch(allUnitsProvider);

    final pickedUnitId = useState<String?>(null);
    final rememberedUnitId = useMemoized(() => ref.read(foodUnitPreferencesProvider)[food.id]);
    // The server counts a unitless ingredient in pieces, so its price is suggested per piece.
    final pieceUnitId = unitsAsync.value?.piece?.id;
    final ingredientUnitId = ingredient == null ? null : ingredient!.unitId ?? pieceUnitId;
    final selectedUnitId = pickedUnitId.value ?? ingredientUnitId ?? rememberedUnitId ?? food.defaultUnitId;
    final currency = ref.watch(householdProvider).value?.currency;
    final hasInitialized = useRef(false);

    // Pre-fill price & amount from the most recent recorded entry, only on the
    // first load — later reloads (e.g. after saving) must not refill the form.
    useEffect(() {
      if (hasInitialized.value) return null;
      final prices = pricesAsync.value;
      if (prices == null) return null;
      hasInitialized.value = true;
      if (prices.data.isEmpty || priceController.text.isNotEmpty) return null;

      final latest = prices.data.first;
      priceController.text = latest.price.formatAmount;
      if (amountController.text == defaultAmount) {
        amountController.text = latest.amount.formatAmount;
      }
      return null;
    }, [pricesAsync.value]);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      if (selectedUnitId == null) return;
      final saved = await recordPriceMutation.tryRun(
        ref,
        (tsx) => tsx
            .get(foodCatalogProvider)
            .recordPrice(
              food,
              priceController.text.asDecimal!,
              amountController.text.asDecimal!,
              selectedUnitId,
            ),
      );
      if (saved && context.mounted) {
        priceController.clear();
        amountController.text = defaultAmount;
      }
    }

    Future<void> deletePrice(FoodPrice price) =>
        // Keyed per price: swipes can overlap, and a mutation only reports its latest run.
        deletePriceMutation(
          price.id,
        ).tryRun(ref, (tsx) => tsx.get(foodCatalogProvider).deletePrice(food.id, price.id));

    return StandardBottomSheet(
      title: context.l10n.foodPriceTitle(food.name),
      maxHeightFraction: 0.8,
      expandChild: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.foodPriceAddTitle,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: UIConstants.paddingMedium),
                TextFormField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: context.l10n.foodPricePrice,
                    hintText: context.l10n.foodPricePriceHint,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return context.l10n.validatorFieldRequired;
                    return Validator.positiveNumber(v, context.l10n);
                  },
                ),
                const SizedBox(height: UIConstants.paddingSmall),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: context.l10n.foodPriceAmount,
                          hintText: context.l10n.foodPriceAmountHint,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.l10n.validatorFieldRequired;
                          return Validator.positiveNumber(v, context.l10n);
                        },
                      ),
                    ),
                    const SizedBox(width: UIConstants.paddingSmall),
                    Expanded(
                      flex: 3,
                      child: UnitPickerFormField(
                        unitsAsync: unitsAsync,
                        selectedUnitId: selectedUnitId,
                        onSelected: (u) => pickedUnitId.value = u.id,
                        validator: (_) => selectedUnitId == null ? context.l10n.validatorFieldRequired : null,
                      ),
                    ),
                  ],
                ),
                if (selectedUnitId != null)
                  _ConversionSection(
                    food: food,
                    selectedUnitId: selectedUnitId,
                    unitsAsync: unitsAsync,
                    prices: pricesAsync.value?.data ?? const [],
                  ),
                const SizedBox(height: UIConstants.paddingMedium),
                LoadingButton(
                  isLoading: isSaving,
                  onPressed: submit,
                  child: Text(context.l10n.foodPriceAddTitle),
                ),
                const SizedBox(height: UIConstants.paddingMedium),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              0,
              UIConstants.paddingMedium,
              0,
              UIConstants.paddingSmall,
            ),
            child: Text(
              context.l10n.foodPriceHistory,
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: pricesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Text(
                  context.l10n.errorSomethingWentWrong,
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colors.error),
                ),
              ),
              data: (page) {
                if (page.data.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(UIConstants.paddingContent),
                    child: Text(
                      context.l10n.foodPriceHistoryEmpty,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: page.data.length,
                  itemBuilder: (context, index) {
                    final price = page.data[index];
                    return DismissibleTile(
                      key: ValueKey(price.id),
                      label: price.unit?.name ?? '',
                      onDelete: () => deletePrice(price),
                      child: _PriceHistoryTile(price: price, currency: currency),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Unit conversion section ────────────────────────────────────────────────

class _ConversionSection extends ConsumerWidget {
  const _ConversionSection({
    required this.food,
    required this.selectedUnitId,
    required this.unitsAsync,
    this.prices = const [],
  });

  final Food food;
  final String selectedUnitId;
  final AsyncValue<List<Unit>> unitsAsync;
  final List<FoodPrice> prices;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, FoodUnitConversion conversion) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.l10n.foodConversionDeleteTitle,
      content: context.l10n.foodConversionDeleteContent(food.name),
      confirmLabel: context.l10n.delete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await deleteConversionMutation.tryRun(
      ref,
      (tsx) => tsx.get(foodCatalogProvider).deleteConversion(food.id, conversion.id),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversionsAsync = ref.watch(foodConversionsProvider(food.id));
    final existing = conversionsAsync.value?.where((c) => c.unitId == selectedUnitId).firstOrNull;
    final selectedUnit = unitsAsync.value?.where((u) => u.id == selectedUnitId).firstOrNull;
    final unitName = selectedUnit?.name ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: UIConstants.paddingSmall),
        Row(
          children: [
            Text(
              context.l10n.foodConversionTitle,
              style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const Spacer(),
            if (existing != null) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: context.l10n.save,
                visualDensity: VisualDensity.compact,
                onPressed: () => FoodConversionBottomSheet.show(
                  context,
                  food: food,
                  unitId: selectedUnitId,
                  unitName: unitName,
                  prices: prices,
                  existing: existing,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: context.colors.error),
                tooltip: context.l10n.delete,
                visualDensity: VisualDensity.compact,
                onPressed: () => _confirmDelete(context, ref, existing),
              ),
            ],
          ],
        ),
        if (existing != null)
          Row(
            children: [
              const Icon(Icons.balance_outlined, size: 16),
              const SizedBox(width: UIConstants.paddingSmall),
              Text(
                context.l10n.foodConversionSummary(
                  unitName,
                  existing.targetAmount.formatAmount,
                  existing.targetUnit?.name ?? existing.targetUnitId,
                ),
                style: context.textTheme.bodyMedium,
              ),
            ],
          )
        else if (conversionsAsync.isLoading)
          const SizedBox.shrink()
        else
          OutlinedButton.icon(
            onPressed: () => FoodConversionBottomSheet.show(
              context,
              food: food,
              unitId: selectedUnitId,
              unitName: unitName,
              prices: prices,
            ),
            icon: const Icon(Icons.balance_outlined, size: 18),
            label: Text(context.l10n.foodConversionSetButton(unitName)),
          ),
      ],
    );
  }
}

// ── Price history tile ─────────────────────────────────────────────────────

class _PriceHistoryTile extends StatelessWidget {
  const _PriceHistoryTile({required this.price, this.currency});

  final FoodPrice price;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    final formatter = context.currencyFormatter(currency);
    final amountStr = price.amount.formatAmount;

    return ListTile(
      dense: true,
      title: Text(
        formatter.format(price.price),
        style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: price.unit != null
          ? Text(
              context.l10n.foodPricePerAmountUnit(amountStr, price.unit!.name),
              style: context.textTheme.bodySmall,
            )
          : null,
      trailing: Text(
        DateFormat.yMd(context.l10n.localeName).format(price.created),
        style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
      ),
    );
  }
}
