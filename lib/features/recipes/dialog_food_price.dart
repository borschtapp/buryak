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
    final ingredientUnit = ingredient == null ? null : ingredient!.unit ?? unitsAsync.value?.unitOrPiece(ingredient!.unitId);
    // The newest price's unit as of the first load, so deleting that price doesn't switch units.
    final historyUnitId = useMemoized(() => pricesAsync.value?.data.firstOrNull?.unitId, [pricesAsync.hasValue]);
    final selectedUnitId =
        pickedUnitId.value ?? ingredient?.unitId ?? ingredientUnit?.id ?? rememberedUnitId ?? food.defaultUnitId ?? historyUnitId;
    final currency = ref.watch(householdProvider).value?.currency;
    final formatter = context.currencyFormatter(currency);
    final hasInitialized = useRef(false);
    final empty = (price: '', amount: defaultAmount);
    // What the form was last filled with, so only fields the user hasn't edited are refilled.
    final filled = useRef(empty);

    void fill(({String price, String amount}) values) {
      filled.value = values;
      priceController.text = values.price;
      amountController.text = values.amount;
    }

    // Fills price & amount from the most recent entry in [unitId], or empties them when it has none.
    void fillFrom(String? unitId) {
      if (priceController.text != filled.value.price || amountController.text != filled.value.amount) return;
      final latest = pricesAsync.value?.data.where((p) => p.unitId == unitId).firstOrNull;
      fill(latest == null ? empty : (price: latest.price.formatAmount, amount: latest.amount.formatAmount));
    }

    // Pre-fill on the first load only — later reloads (e.g. after saving) must not refill
    // the form. Waits for the units too: until they load, a unitless ingredient's piece
    // unit is unknown and another unit is selected.
    useEffect(() {
      if (hasInitialized.value) return null;
      if (!pricesAsync.hasValue || unitsAsync.isLoading) return null;
      hasInitialized.value = true;
      fillFrom(selectedUnitId);
      return null;
    }, [pricesAsync.value, unitsAsync.isLoading]);

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
      if (saved && context.mounted) fill(empty);
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
      // One scroll view, so the form scrolls along with the history when the sheet is short.
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverToBoxAdapter(
            child: Form(
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
                      // The symbol goes where the locale writes it: "€3.00", "3,00 €".
                      // Without a currency the formatter falls back to the locale's, which may not be the household's.
                      prefixText: currency != null ? formatter.positivePrefix : null,
                      suffixText: currency != null ? formatter.positiveSuffix : null,
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
                          onSelected: (u) {
                            pickedUnitId.value = u.id;
                            // A price only holds for the unit it was recorded in.
                            fillFrom(u.id);
                          },
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
                      ingredientUnit: ingredientUnit,
                      prices: pricesAsync.value?.data ?? const [],
                    ),
                  const SizedBox(height: UIConstants.paddingMedium),
                  LoadingButton(
                    isLoading: isSaving,
                    onPressed: submit,
                    child: Text(context.l10n.foodPriceAddTitle),
                  ),
                  const SizedBox(height: UIConstants.paddingMedium),
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
                ],
              ),
            ),
          ),
          pricesAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(UIConstants.paddingContent),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, _) => SliverToBoxAdapter(
              child: Center(
                child: Text(
                  context.l10n.errorSomethingWentWrong,
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colors.error),
                ),
              ),
            ),
            data: (page) {
              if (page.data.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.paddingContent),
                    child: Text(
                      context.l10n.foodPriceHistoryEmpty,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return SliverList.builder(
                itemCount: page.data.length,
                itemBuilder: (context, index) {
                  final price = page.data[index];
                  return DismissibleTile(
                    key: ValueKey(price.id),
                    label: price.unit?.name ?? '',
                    onDelete: () => deletePrice(price),
                    child: _PriceHistoryTile(price: price, formatter: formatter),
                  );
                },
              );
            },
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
    this.ingredientUnit,
    this.prices = const [],
  });

  final Food food;
  final String selectedUnitId;
  final AsyncValue<List<Unit>> unitsAsync;

  /// The unit the recipe counts the food in, when opened for an ingredient.
  final Unit? ingredientUnit;
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
    final conversions = conversionsAsync.value ?? const <FoodUnitConversion>[];
    final unitsById = (unitsAsync.value ?? const <Unit>[]).byId;
    final selectedUnit = unitsById[selectedUnitId];

    // A recipe amount the price can't scale to needs a conversion linking the two units.
    final link = switch ((ingredientUnit, selectedUnit)) {
      (final Unit from, final Unit to) when !from.scalesTo(to) => (from: from, to: to),
      _ => null,
    };
    final linking = link == null ? null : conversions.linking(link.from, link.to, unitsById);
    // Without one, offer the conversion that would link them; there may be none (cans and pieces).
    final bridge = link != null && linking == null ? bridgingConversion(link.from, link.to) : null;
    final unlinkable = linking == null && bridge == null ? link : null;

    final source = linking?.sourceUnitIn(unitsById) ?? bridge?.source ?? selectedUnit;
    final sourceId = source?.id ?? selectedUnitId;
    final sourceName = source?.name ?? '';
    // A food has at most one conversion per source unit, so a bridge retargets the existing one.
    final existing = linking ?? conversions.fromUnit(sourceId);
    // Units that can't be linked get no conversion: one for the price unit can't price the recipe's amount.
    final shown = bridge == null && unlinkable == null ? existing : null;

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
            if (shown != null) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: context.l10n.save,
                visualDensity: VisualDensity.compact,
                onPressed: () => FoodConversionBottomSheet.show(
                  context,
                  food: food,
                  unitId: sourceId,
                  unitName: sourceName,
                  prices: prices,
                  existing: shown,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: context.colors.error),
                tooltip: context.l10n.delete,
                visualDensity: VisualDensity.compact,
                onPressed: () => _confirmDelete(context, ref, shown),
              ),
            ],
          ],
        ),
        if (unlinkable != null)
          Padding(
            padding: const EdgeInsets.only(bottom: UIConstants.paddingSmall),
            child: Text(
              context.l10n.foodPriceUnitsUnlinkable(unlinkable.from.name, unlinkable.to.name),
              style: context.textTheme.bodySmall?.copyWith(color: context.colors.error),
            ),
          ),
        if (shown != null)
          Row(
            children: [
              const Icon(Icons.balance_outlined, size: 16),
              const SizedBox(width: UIConstants.paddingSmall),
              Text(
                context.l10n.foodConversionSummary(
                  sourceName,
                  shown.targetAmount.formatAmount,
                  shown.targetUnitIn(unitsById)?.name ?? shown.targetUnitId,
                ),
                style: context.textTheme.bodyMedium,
              ),
            ],
          )
        else if (conversionsAsync.isLoading || unlinkable != null)
          const SizedBox.shrink()
        else ...[
          if (link != null && bridge != null)
            Padding(
              padding: const EdgeInsets.only(bottom: UIConstants.paddingSmall),
              child: Text(
                context.l10n.foodPriceConversionNeeded(link.from.name, link.to.name),
                style: context.textTheme.bodySmall?.copyWith(color: context.colors.tertiary),
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => FoodConversionBottomSheet.show(
              context,
              food: food,
              unitId: sourceId,
              unitName: sourceName,
              prices: prices,
              existing: existing,
              targetUnitId: bridge?.target.id,
            ),
            icon: const Icon(Icons.balance_outlined, size: 18),
            label: Text(context.l10n.foodConversionSetButton(sourceName)),
          ),
        ],
      ],
    );
  }
}

// ── Price history tile ─────────────────────────────────────────────────────

class _PriceHistoryTile extends StatelessWidget {
  const _PriceHistoryTile({required this.price, required this.formatter});

  final FoodPrice price;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
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
