import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/recipes/controller_recipe.dart';
import '../../features/shopping/notifier_shopping.dart';
import '../repositories/food_repository.dart';
import '../repositories/unit_repository.dart';
import 'recipe_price.dart';

part 'food_catalog.g.dart';

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
    String? defaultUnitId,
    bool clearDefaultUnit = false,
    bool? pantry,
  }) async {
    final unitChanged = defaultUnitId != null || clearDefaultUnit;
    if (name == null && !unitChanged && pantry == null) return;
    await _foods.update(
      foodId,
      name: name,
      defaultUnitId: defaultUnitId,
      clearDefaultUnit: clearDefaultUnit,
      pantry: pantry,
    );
    _ref.invalidate(recipeControllerProvider);
    // Shopping items embed the food, so a rename shows there too.
    if (name != null) _ref.invalidate(shoppingItemsProvider);
    // A rename can't move a cost estimate; pantry and default unit can.
    if (unitChanged || pantry != null) _ref.invalidate(recipeCostEstimateProvider);
  }

  Future<void> mergeFoods(String sourceId, String targetId) async {
    await _foods.merge(sourceId, targetId);
    _foodsReassigned();
  }

  Future<void> recordPrice(String foodId, double price, double amount, String unitId) async {
    await _foods.recordPrice(foodId, price, amount, unitId);
    _ref.read(foodUnitPreferencesProvider.notifier).setPreferred(foodId, unitId);
    _pricesChanged(foodId);
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
  void _foodsReassigned() => _ref
    ..invalidate(foodPricesProvider)
    ..invalidate(foodConversionsProvider)
    ..invalidate(recipeCostEstimateProvider)
    ..invalidate(recipeControllerProvider)
    ..invalidate(shoppingItemsProvider);
}
