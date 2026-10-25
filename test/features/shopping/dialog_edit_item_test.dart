import 'package:buryak/features/shopping/dialog_edit_item.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/shopping_item.dart';
import 'package:buryak/shared/models/unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  Future<void> pumpSheet(WidgetTester tester, ShoppingItem item) => tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: EditShoppingItemBottomSheet(key: ValueKey(item.id), item: item)),
      ),
    ),
  );

  testWidgets('an item whose amount was cleared can be given one again', (tester) async {
    await pumpSheet(
      tester,
      const ShoppingItem(
        id: 'i1',
        text: 'Flour',
        unitId: 'g',
        unit: Unit(id: 'g', slug: 'g', name: 'g'),
      ),
    );

    expect(find.widgetWithText(TextField, 'Amount'), findsOneWidget);
  });

  testWidgets('an item with an amount focuses the amount, one without focuses the name', (tester) async {
    bool hasFocus(String label) => tester
        .widget<EditableText>(find.descendant(of: find.widgetWithText(TextField, label), matching: find.byType(EditableText)))
        .focusNode
        .hasFocus;
    const unit = Unit(id: 'g', slug: 'g', name: 'g');

    await pumpSheet(tester, const ShoppingItem(id: 'i1', text: 'Flour', amount: 200, unitId: 'g', unit: unit));
    await tester.pump();
    expect(hasFocus('Amount'), isTrue);

    await pumpSheet(tester, const ShoppingItem(id: 'i2', text: 'Salt', foodId: 'salt'));
    await tester.pump();
    expect(hasFocus('Amount'), isFalse);
    expect(hasFocus('Name'), isTrue);
  });

  testWidgets('a free-text item has no amount field', (tester) async {
    await pumpSheet(tester, const ShoppingItem(id: 'i1', text: 'Something tasty'));

    expect(find.widgetWithText(TextField, 'Amount'), findsNothing);
  });
}
