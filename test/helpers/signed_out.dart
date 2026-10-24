import 'package:buryak/shared/providers/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/misc.dart' show ProviderException;

/// Matches a [SignedOutError], also when Riverpod rethrows it wrapped in a
/// [ProviderException] on its way through a dependent provider.
final throwsSignedOut = throwsA(
  anyOf(
    isA<SignedOutError>(),
    isA<ProviderException>().having((e) => e.exception, 'exception', isA<SignedOutError>()),
  ),
);
