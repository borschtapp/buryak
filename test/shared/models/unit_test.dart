import 'package:buryak/shared/models/unit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_units.dart';

void main() {
  test('Unit.isPiece matches only the built-in piece unit', () {
    expect(piece.isPiece, isTrue);
    expect(gram.isPiece, isFalse);
  });

  group('Unit.isConversionTargetFor', () {
    test('a counted unit converts to any measurable unit', () {
      expect(gram.isConversionTargetFor(piece), isTrue);
      expect(kilogram.isConversionTargetFor(piece), isTrue);
      expect(cup.isConversionTargetFor(piece), isTrue);
    });

    test('a measurable unit converts to another kind of measure', () {
      expect(gram.isConversionTargetFor(cup), isTrue);
    });

    test('rejects units the server would not convert into', () {
      expect(piece.isConversionTargetFor(gram), isFalse, reason: 'not measurable');
      expect(piece.isConversionTargetFor(piece), isFalse, reason: 'same unit');
      expect(gram.isConversionTargetFor(kilogram), isFalse, reason: 'already scales by its base');
      expect(kilogram.isConversionTargetFor(kilogram), isFalse, reason: 'same unit');
    });
  });

  group('bridgingConversion', () {
    test('converts a counted ingredient into the price unit', () {
      final bridge = bridgingConversion(piece, kilogram)!;
      expect((bridge.source.id, bridge.target.id), ('pc', 'kg'));
    });

    test('converts a counted price unit into the ingredient unit', () {
      final bridge = bridgingConversion(gram, piece)!;
      expect((bridge.source.id, bridge.target.id), ('pc', 'g'));
    });

    test('converts between kinds of measure from the ingredient unit', () {
      final bridge = bridgingConversion(cup, kilogram)!;
      expect((bridge.source.id, bridge.target.id), ('cup', 'kg'));
    });

    test('cannot bridge two counted units with one conversion', () {
      expect(bridgingConversion(piece, can), isNull);
    });
  });
}
