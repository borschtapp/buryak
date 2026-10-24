import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/components/picker_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget field(String label) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: PickerFormField<String>(
        selectionKey: 'u1',
        selectionLabel: label,
        labelText: 'Unit',
        pick: (_) async => null,
        onSelected: (_) {},
      ),
    ),
  );

  testWidgets('shows the new label when the selected item is renamed', (tester) async {
    await tester.pumpWidget(field('g'));
    await tester.pumpWidget(field('gram'));

    expect(find.text('gram'), findsOneWidget);
  });
}
