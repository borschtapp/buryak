import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/components/standard_async_builder.dart';
import 'package:buryak/shared/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('the default error state shows the localized error message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: StandardAsyncBuilder<int>(
            value: AsyncError(GeneralApiException(message: '', statusCode: 404), StackTrace.empty),
            data: (_) => const SizedBox(),
          ),
        ),
      ),
    );

    expect(find.text(lookupAppLocalizations(const Locale('en')).errorNotFound), findsOneWidget);
  });
}
