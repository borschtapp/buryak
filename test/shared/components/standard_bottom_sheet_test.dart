import 'package:buryak/shared/components/standard_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('showAppBottomSheet lifts the sheet body above the keyboard', (tester) async {
    const keyboard = 300.0;
    tester.view.viewInsets = FakeViewPadding(bottom: keyboard * tester.view.devicePixelRatio);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAppBottomSheet<void>(
              context: context,
              builder: (_) => const SizedBox(key: Key('body'), height: 100),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(tester.getBottomLeft(find.byKey(const Key('body'))).dy, screenHeight - keyboard);
  });
}
