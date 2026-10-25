import 'package:buryak/shared/models/food_price.dart';
import 'package:buryak/shared/models/unit.dart';

// Counted units: the server leaves out their base factor.
const piece = Unit(id: 'pc', slug: 'pc', name: 'piece');
const can = Unit(id: 'can', slug: 'can', name: 'can');

const gram = Unit(id: 'g', slug: 'g', name: 'gram', baseFactor: 1);
const kilogram = Unit(id: 'kg', slug: 'kg', name: 'kilogram', baseUnitId: 'g', baseFactor: 1000);
const milliliter = Unit(id: 'ml', slug: 'ml', name: 'milliliter', baseFactor: 1);
const cup = Unit(id: 'cup', slug: 'cup', name: 'cup', baseUnitId: 'ml', baseFactor: 240);

/// An onion priced at 2 per one [unitId].
FoodPrice fakeOnionPrice(String unitId) => FoodPrice(
  id: 'p1',
  foodId: 'onion',
  unitId: unitId,
  householdId: 'h1',
  price: 2,
  amount: 1,
  created: DateTime(2026),
);
