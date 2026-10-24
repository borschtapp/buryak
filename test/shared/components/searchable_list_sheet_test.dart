import 'dart:async';
import 'dart:io';

import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/components/searchable_list_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  Finder listScrollable() => find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable));

  testWidgets('a filterable sheet shows new items without a loading state or losing scroll', (tester) async {
    final items = ValueNotifier(List.generate(50, (i) => 'item $i'));
    await tester.pumpWidget(
      host(
        ValueListenableBuilder(
          valueListenable: items,
          builder: (_, list, _) => FilterableListSheet<String>(
            items: list,
            filter: (s, query) => s.contains(query),
            itemBuilder: (_, s) => ListTile(title: Text(s)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    final offset = tester.state<ScrollableState>(listScrollable()).position.pixels;
    expect(offset, greaterThan(0));

    items.value = [for (final s in items.value) '$s!'];
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.textContaining('!'), findsWidgets);
    expect(tester.state<ScrollableState>(listScrollable()).position.pixels, offset);
  });

  testWidgets('a filterable sheet narrows by the trimmed, lower-cased query', (tester) async {
    await tester.pumpWidget(
      host(
        FilterableListSheet<String>(
          items: const ['Gram', 'Kilogram', 'Cup'],
          filter: (s, query) => s.toLowerCase().contains(query),
          itemBuilder: (_, s) => ListTile(title: Text(s)),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), ' GRAM ');
    await tester.pump();

    expect(find.text('Gram'), findsOneWidget);
    expect(find.text('Kilogram'), findsOneWidget);
    expect(find.text('Cup'), findsNothing);
  });

  testWidgets('an async search keeps the current results visible while the next one loads', (tester) async {
    final pending = <String, Completer<List<String>>>{};
    await tester.pumpWidget(
      host(
        SearchableListSheet<String>(
          debounceDuration: Duration.zero,
          search: (query) => (pending[query] = Completer<List<String>>()).future,
          itemBuilder: (_, s) => ListTile(title: Text(s)),
        ),
      ),
    );
    // The debounce timer only fires once fake time actually advances.
    const tick = Duration(milliseconds: 1);
    await tester.pump(tick);
    expect(find.byType(CircularProgressIndicator), findsOneWidget, reason: 'nothing to show yet');
    pending['']!.complete(['apple', 'apricot']);
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'ap');
    await tester.pump(); // rebuild with the new query, which starts the debounce timer
    await tester.pump(tick); // the timer fires and the search starts
    await tester.pump(); // the loading state it set is drawn

    expect(find.text('apple'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    pending['ap']!.complete(['apricot']);
    await tester.pump();
    expect(find.text('apple'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('a failed async search shows an error with retry instead of "no results"', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: SearchableListSheet<String>(
            debounceDuration: Duration.zero,
            emptyResultsText: 'No results',
            search: (query) async {
              if (attempts++ == 0) throw const SocketException('offline');
              return ['tomato'];
            },
            itemBuilder: (_, s) => ListTile(title: Text(s)),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(find.text('No results'), findsNothing);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.errorConnectionIssue), findsOneWidget);

    await tester.tap(find.text(l10n.errorTryAgain));
    await tester.pump();
    await tester.pump();

    expect(find.text('tomato'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('a filterable sheet whose items failed to load shows an error with retry', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: FilterableListSheet<String>(
            items: const [],
            error: const SocketException('offline'),
            onRetry: () => retries++,
            emptyResultsText: 'No results',
            filter: (s, query) => s.contains(query),
            itemBuilder: (_, s) => ListTile(title: Text(s)),
          ),
        ),
      ),
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text('No results'), findsNothing);
    expect(find.text(l10n.errorConnectionIssue), findsOneWidget);
    await tester.tap(find.text(l10n.errorTryAgain));
    expect(retries, 1);
  });
}
