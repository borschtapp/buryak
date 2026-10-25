import 'package:freezed_annotation/freezed_annotation.dart';

import 'taxonomy.dart';

part 'unit.freezed.dart';
part 'unit.g.dart';

@freezed
abstract class Unit with _$Unit {
  const Unit._();

  const factory Unit({
    required String id,
    required String slug,
    required String name,
    String? canonicalUnitId,
    // Set on derived units (kg → g); base units have none.
    String? baseUnitId,
    // Multiplier to the base unit; the server omits it for counted units (piece, can).
    double? baseFactor,

    // Preload fields
    List<Taxonomy>? taxonomies,
  }) = _Unit;

  /// Whether this is the built-in piece unit, which the server counts unitless
  /// amounts in and won't merge into another unit.
  bool get isPiece => slug == 'pc';

  /// Whether amounts in this unit can be measured (g, kg, ml, l, cm …).
  bool get isMeasurable => (baseFactor ?? 0) != 0;

  /// Whether a food conversion from [source] may target this unit. The server
  /// accepts any measurable target other than [source]; a target that scales
  /// to the same base (1 kg = 900 g) is also left out, as the server scales
  /// those units directly and would never apply it.
  bool isConversionTargetFor(Unit source) {
    if (!isMeasurable) return false;
    return !source.isMeasurable || (baseUnitId ?? id) != (source.baseUnitId ?? source.id);
  }

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
}

extension UnitLookup on Iterable<Unit> {
  /// The built-in piece unit, which the server counts unitless amounts in.
  Unit? get piece => where((u) => u.isPiece).firstOrNull;

  Map<String, Unit> get byId => {for (final unit in this) unit.id: unit};
}

/// The food conversion that lets an amount in [ingredientUnit] be priced per [priceUnit]:
/// from the ingredient's unit when it can target the price's, else the other way round.
/// Null when no single conversion links them (e.g. pieces and cans).
({Unit source, Unit target})? bridgingConversion(Unit ingredientUnit, Unit priceUnit) {
  if (priceUnit.isConversionTargetFor(ingredientUnit)) return (source: ingredientUnit, target: priceUnit);
  if (ingredientUnit.isConversionTargetFor(priceUnit)) return (source: priceUnit, target: ingredientUnit);
  return null;
}
