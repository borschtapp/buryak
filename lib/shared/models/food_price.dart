import 'package:freezed_annotation/freezed_annotation.dart';

import 'food.dart';
import 'unit.dart';

part 'food_price.freezed.dart';
part 'food_price.g.dart';

@freezed
abstract class FoodPrice with _$FoodPrice {
  const factory FoodPrice({
    required String id,
    required String foodId,
    required String unitId,
    required String householdId,
    required double price,
    required double amount,
    required DateTime created,

    // Preload fields
    Food? food,
    Unit? unit,
  }) = _FoodPrice;

  factory FoodPrice.fromJson(Map<String, dynamic> json) => _$FoodPriceFromJson(json);
}
