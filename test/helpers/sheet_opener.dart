import 'package:buryak/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart' show Override;

/// Pumps a routed page whose "open" button runs [show], then taps it, so sheets and
/// dialogs open (and `context.pop` them) as in the app. Uses [container] when given,
/// else a new scope with [overrides] and [observers].
Future<void> pumpAndOpen(
  WidgetTester tester,
  void Function(BuildContext context) show, {
  ProviderContainer? container,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: TextButton(onPressed: () => show(context), child: const Text('open')),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  final app = MaterialApp.router(localizationsDelegates: AppLocalizations.localizationsDelegates, routerConfig: router);
  await tester.pumpWidget(
    container != null
        ? UncontrolledProviderScope(container: container, child: app)
        : ProviderScope(overrides: overrides, observers: observers, child: app),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}
