import 'dart:convert';

import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'fake_auth.dart';

class MockClient extends Mock implements http.Client {}

/// The repository under test and the [MockClient] it sends through, rebuilt for every test.
class RepositoryHarness<R> {
  late MockClient client;
  late R repository;
}

/// Registers the setup that builds a fresh repository with [create] for every test,
/// signed in as [user] (signed out by default). Call it from `main`.
RepositoryHarness<R> setUpRepository<R>(R Function(Ref ref, http.Client client) create, {User? user}) {
  final harness = RepositoryHarness<R>();

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(Uri.parse('https://example.com'));
    FlutterSecureStorage.setMockInitialValues({});
  });

  setUp(() {
    harness.client = MockClient();
    final container = ProviderContainer(overrides: [authProvider.overrideWith(() => FakeAuthNotifier(user))]);
    addTearDown(container.dispose);
    harness.repository = create(container.read(Provider<Ref>((ref) => ref)), harness.client);
  });

  return harness;
}

/// Answers every [method] request on [client] with [body] as JSON and [status].
void respond(MockClient client, RequestMethod method, {Object? body, int status = 200}) {
  when(() => _send(client, method, () => any(named: 'body'))).thenAnswer((_) async => http.Response(jsonEncode(body ?? {}), status));
}

/// Answers [method] requests on [client] with [response], runs [call], and returns the
/// decoded JSON body it sent.
Future<dynamic> sentBody(MockClient client, RequestMethod method, Future<void> Function() call, {Object? response}) async {
  respond(client, method, body: response);
  await call();
  final body = verify(() => _send(client, method, () => captureAny(named: 'body'))).captured.single;
  return jsonDecode(body as String);
}

/// [body] builds the body matcher; GET takes no body, so it is never called for one.
Future<http.Response> _send(MockClient client, RequestMethod method, Object? Function() body) => switch (method) {
  .get => client.get(any(), headers: any(named: 'headers')),
  .post => client.post(
    any(),
    headers: any(named: 'headers'),
    body: body(),
  ),
  .put => client.put(
    any(),
    headers: any(named: 'headers'),
    body: body(),
  ),
  .patch => client.patch(
    any(),
    headers: any(named: 'headers'),
    body: body(),
  ),
  .delete => client.delete(
    any(),
    headers: any(named: 'headers'),
    body: body(),
  ),
};
