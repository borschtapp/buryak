import 'package:buryak/shared/components/standard_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('showAppBottomSheet lifts the sheet body above the keyboard on mobile', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 600 * 3);
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

  testWidgets('showAppBottomSheet renders a centered Dialog on desktop', (tester) async {
    // Default tester view has width 800 > 730 (tablet/desktop)
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAppBottomSheet<void>(
              context: context,
              builder: (_) => const SizedBox(key: Key('body'), height: 100, width: 200),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  for (final (name, width, draggable) in [('mobile', 400.0, true), ('desktop', 800.0, false)]) {
    testWidgets('showAppDraggableSheet ${draggable ? 'passes' : 'withholds'} the scroll controller on $name', (tester) async {
      tester.view.physicalSize = Size(width * 3, 600 * 3);
      addTearDown(tester.view.reset);
      ScrollController? received;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAppDraggableSheet<void>(
                context: context,
                builder: (_, scrollController) {
                  received = scrollController;
                  return ListView(controller: scrollController, children: const [Text('body')]);
                },
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('body'), findsOneWidget);
      expect(find.byType(DraggableScrollableSheet), draggable ? findsOneWidget : findsNothing);
      expect(received, draggable ? isNotNull : isNull);
    });
  }
}
