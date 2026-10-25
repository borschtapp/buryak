import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/components/recipes/dialog_edit_unit.dart';
import 'package:buryak/shared/models/unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  Future<AppLocalizations> pumpSheet(WidgetTester tester, Unit unit) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: EditUnitBottomSheet(key: ValueKey(unit.id), unit: unit),
          ),
        ),
      ),
    );
    return AppLocalizations.of(tester.element(find.byType(EditUnitBottomSheet)));
  }

  testWidgets('a unit can be merged into another', (tester) async {
    final l10n = await pumpSheet(tester, const Unit(id: 'g', slug: 'g', name: 'gram'));

    expect(find.text(l10n.editUnitMerge), findsOneWidget);
  });

  testWidgets('the built-in piece unit can be renamed but not merged away', (tester) async {
    final l10n = await pumpSheet(tester, const Unit(id: 'pc', slug: 'pc', name: 'piece'));

    expect(find.text(l10n.editUnitName), findsOneWidget);
    expect(find.text(l10n.editUnitMerge), findsNothing);
  });
}
