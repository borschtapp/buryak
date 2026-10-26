import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/food.dart';
import '../repositories/food_repository.dart';
import '../repositories/unit_repository.dart';
import 'recipe_price.dart';

part 'food_catalog.g.dart';

/// Caches that embed foods, so a catalog write must reload them.
enum FoodEmbedder { recipes, shoppingItems }

/// Bumped when a catalog write changes what [embedder] shows; it watches this to reload.
@Riverpod(keepAlive: true)
class FoodCatalogChanged extends _$FoodCatalogChanged {
  @override
  int build(FoodEmbedder embedder) => 0;

  void trigger() => state++;
}

// Mutations for the catalog writes below. Run them with `tsx.get(foodCatalogProvider)`;
// sheets watch them for pending state, and failures reach the user through
// `MutationErrorReporter`.
final updateFoodMutation = Mutation<void>(label: 'updateFood');
final mergeFoodsMutation = Mutation<void>(label: 'mergeFoods');
final recordPriceMutation = Mutation<void>(label: 'recordPrice');

/// Key it with the price id (`deletePriceMutation(priceId)`), since deletes can overlap.
final deletePriceMutation = Mutation<void>(label: 'deletePrice');
final saveConversionMutation = Mutation<void>(label: 'saveConversion');
final deleteConversionMutation = Mutation<void>(label: 'deleteConversion');
final renameUnitMutation = Mutation<void>(label: 'renameUnit');
final mergeUnitsMutation = Mutation<void>(label: 'mergeUnits');

@Riverpod(keepAlive: true)
FoodCatalog foodCatalog(Ref ref) => FoodCatalog(ref);

/// Household-wide writes to foods, units, prices and conversions.
///
/// Each method sends the request, then refreshes every cache derived from the
/// changed data, so that fan-out lives in one place instead of in each sheet.
/// It runs on this keepAlive provider's [Ref], which outlives whichever sheet
/// started the write.
class FoodCatalog {
  FoodCatalog(this._ref);

  final Ref _ref;

  FoodRepository get _foods => _ref.read(foodRepositoryProvider);
  UnitRepository get _units => _ref.read(unitRepositoryProvider);

  /// Pass only the fields that changed; with none, nothing is sent.
  Future<void> updateFood(
    String foodId, {
    String? name,
    String? description,
    String? defaultUnitId,
    bool clearDefaultUnit = false,
    bool? pantry,
  }) async {
    final unitChanged = defaultUnitId != null || clearDefaultUnit;
    if (name == null && description == null && !unitChanged && pantry == null) return;
    await _foods.update(
      foodId,
      name: name,
      description: description,
      defaultUnitId: defaultUnitId,
      clearDefaultUnit: clearDefaultUnit,
      pantry: pantry,
    );
    // Recipes embed the whole food; shopping items show only its name.
    _changed(FoodEmbedder.recipes);
    if (name != null) _changed(FoodEmbedder.shoppingItems);
    // A rename can't move a cost estimate; pantry and default unit can.
    if (unitChanged || pantry != null) _ref.invalidate(recipeCostEstimateProvider);
  }

  Future<void> mergeFoods(String sourceId, String targetId) async {
    await _foods.merge(sourceId, targetId);
    _foodsReassigned();
  }

  Future<void> recordPrice(Food food, double price, double amount, String unitId) async {
    await _foods.recordPrice(food.id, price, amount, unitId);
    _ref.read(foodUnitPreferencesProvider.notifier).setPreferred(food.id, unitId);
    _pricesChanged(food.id);
    // The server makes the first price's unit the food's default; recipes embed the food.
    if (food.defaultUnitId == null) _changed(FoodEmbedder.recipes);
  }

  Future<void> deletePrice(String foodId, String priceId) async {
    await _foods.deletePrice(foodId, priceId);
    _pricesChanged(foodId);
  }

  /// Creates a conversion, or updates [existingId] when given.
  Future<void> saveConversion(
    String foodId, {
    String? existingId,
    required String unitId,
    required double targetAmount,
    required String targetUnitId,
  }) async {
    if (existingId != null) {
      await _foods.updateConversion(foodId, existingId, targetAmount, targetUnitId);
    } else {
      await _foods.createConversion(foodId, unitId, targetAmount, targetUnitId);
    }
    _conversionsChanged(foodId);
  }

  Future<void> deleteConversion(String foodId, String conversionId) async {
    await _foods.deleteConversion(foodId, conversionId);
    _conversionsChanged(foodId);
  }

  Future<void> renameUnit(String unitId, String name) async {
    await _units.update(unitId, name: name);
    _unitsChanged();
  }

  Future<void> mergeUnits(String sourceId, String targetId) async {
    await _units.merge(sourceId, targetId);
    _ref.read(foodUnitPreferencesProvider.notifier).replaceUnit(sourceId, targetId);
    _unitsChanged();
  }

  void _pricesChanged(String foodId) => _ref
    ..invalidate(foodPricesProvider(foodId))
    ..invalidate(recipeCostEstimateProvider);

  void _conversionsChanged(String foodId) => _ref
    ..invalidate(foodConversionsProvider(foodId))
    ..invalidate(recipeCostEstimateProvider);

  /// Unit renames and merges relabel or reassign units everywhere, including the unit catalog.
  void _unitsChanged() {
    _ref.invalidate(allUnitsProvider);
    _foodsReassigned();
  }

  /// Merges reassign prices, conversions, ingredients and shopping items across the household.
  void _foodsReassigned() {
    _ref
      ..invalidate(foodPricesProvider)
      ..invalidate(foodConversionsProvider)
      ..invalidate(recipeCostEstimateProvider);
    FoodEmbedder.values.forEach(_changed);
  }

  void _changed(FoodEmbedder embedder) => _ref.read(foodCatalogChangedProvider(embedder).notifier).trigger();
}
