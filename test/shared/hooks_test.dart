import 'package:buryak/shared/hooks.dart';
import 'package:buryak/shared/providers/shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A page that publishes a FAB labelled [label] (none when `null`) and can push [next].
class _Page extends HookConsumerWidget {
  const _Page(this.label, {this.next});

  final String? label;
  final _Page? next;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fab = useMemoized(() => label == null ? null : FloatingActionButton(onPressed: null, child: Text('fab $label')));
    useFab(ref, fab);
    return Center(
      child: TextButton(
        onPressed: next == null ? null : () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => next!)),
        child: Text('page ${label ?? 'none'}'),
      ),
    );
  }
}

void main() {
  /// Mirrors the shell: one Scaffold whose FAB slot shows [shellFabProvider],
  /// around a nested navigator that holds the pages.
  Future<void> pumpShell(WidgetTester tester, _Page home) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (_, ref, navigator) => Scaffold(floatingActionButton: ref.watch(shellFabProvider), body: navigator),
            child: Navigator(onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => home)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, String page) async {
    await tester.tap(find.text(page));
    await tester.pumpAndSettle();
  }

  Future<void> back(WidgetTester tester) async {
    tester.state<NavigatorState>(find.byType(Navigator).last).pop();
    await tester.pumpAndSettle();
  }

  testWidgets('a page pushed on top hides the FAB of the page below', (tester) async {
    await pumpShell(tester, const _Page('a', next: _Page(null)));
    expect(find.text('fab a'), findsOneWidget);

    await open(tester, 'page a');
    expect(find.text('fab a'), findsNothing);

    await back(tester);
    expect(find.text('fab a'), findsOneWidget);
  });

  testWidgets('popping a page with its own FAB brings back the FAB below', (tester) async {
    await pumpShell(tester, const _Page('a', next: _Page('b')));

    await open(tester, 'page a');
    expect(find.text('fab b'), findsOneWidget);
    expect(find.text('fab a'), findsNothing);

    await back(tester);
    expect(find.text('fab a'), findsOneWidget);
    expect(find.text('fab b'), findsNothing);
  });
}
