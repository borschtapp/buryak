import 'package:buryak/shared/providers/error_handler.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  test('MutationErrorReporter leaves errors shown inline to their form', () async {
    final container = ProviderContainer(observers: [MutationErrorReporter()]);
    addTearDown(container.dispose);
    final mutation = Mutation<void>(label: 'test');
    final reported = <ErrorMessage?>[];
    container.listen(errorHandlerProvider, (_, next) => reported.add(next));

    await mutation.tryRunFor(container, () => throw WrongPasswordException());
    expect(reported, isEmpty);

    await mutation.tryRunFor(container, () => throw GeneralApiException(message: 'Nope', statusCode: 400));
    expect(reported.map((e) => e?.text), ['Nope']);
  });
}

extension on Mutation<void> {
  Future<void> tryRunFor(ProviderContainer container, Future<void> Function() body) async {
    try {
      await run(container, (_) => body());
    } on Object {
      // The reporter is what is under test.
    }
  }
}
