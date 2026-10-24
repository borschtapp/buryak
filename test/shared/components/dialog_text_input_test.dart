import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/components/dialog_text_input.dart';
import 'package:buryak/shared/providers/error_handler.dart';
import 'package:buryak/shared/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  late Mutation<String> mutation;
  late ProviderContainer container;

  setUp(() {
    mutation = Mutation<String>(label: 'test');
    container = ProviderContainer(observers: [MutationErrorReporter()]);
    addTearDown(container.dispose);
  });

  /// Opens a [TextInputDialog] whose write is [submit], recording what reached `onSuccess`.
  Future<List<String>> open(WidgetTester tester, Future<String> Function(String value) submit) async {
    final successes = <String>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => TextInputDialog<String>(
                title: 'Title',
                hintText: 'Hint',
                submitLabel: 'Submit',
                validator: (value) => value.isEmpty ? 'Required' : null,
                mutation: mutation,
                onSubmit: (_, value) => submit(value),
                onSuccess: successes.add,
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(localizationsDelegates: AppLocalizations.localizationsDelegates, routerConfig: router),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return successes;
  }

  testWidgets('submits the trimmed input, closes, then reports the result', (tester) async {
    final successes = await open(tester, (value) async => 'saved $value');

    await tester.enterText(find.byType(TextField), '  Milk ');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.byType(TextInputDialog<String>), findsNothing);
    expect(successes, ['saved Milk']);
  });

  testWidgets('stays open on failure, which is reported once', (tester) async {
    final errors = <ErrorMessage?>[];
    container.listen(errorHandlerProvider, (_, next) => errors.add(next));
    final successes = await open(tester, (_) async => throw GeneralApiException(message: 'Nope', statusCode: 400));

    await tester.enterText(find.byType(TextField), 'Milk');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.byType(TextInputDialog<String>), findsOneWidget);
    expect(successes, isEmpty);
    expect(errors.map((e) => e?.text), ['Nope']);
  });

  testWidgets('does not submit input that fails validation', (tester) async {
    var calls = 0;
    await open(tester, (value) async {
      calls++;
      return value;
    });

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsOneWidget);
    expect(calls, 0);
  });
}
