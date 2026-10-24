import 'dart:convert';

import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/shopping_list_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements http.Client {}

class FakeAuthNotifier extends AuthNotifier {
  @override
  User? build() => null;

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshLogin({bool force = false}) async => true;
}

void main() {
  late MockClient mockClient;
  late ShoppingListRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(Uri.parse('https://example.com'));
    FlutterSecureStorage.setMockInitialValues({});
  });

  setUp(() {
    mockClient = MockClient();
    container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(FakeAuthNotifier.new),
      ],
    );
    repository = ShoppingListRepository(
      ref: container.read(Provider<Ref>((ref) => ref)),
      client: mockClient,
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ShoppingListRepository', () {
    test('findAll returns a list of shopping lists', () async {
      final listsJson = [
        {'id': '1', 'name': 'Weekly Groceries', 'is_default': true},
      ];
      final responseBody = jsonEncode({
        'data': listsJson,
        'meta': {'page': 1, 'total': 1, 'limit': 20, 'offset': 0},
      });

      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await repository.findAll();
      expect(result.data.length, 1);
      expect(result.data[0].name, 'Weekly Groceries');
    });

    test('findItems returns a list of items', () async {
      final itemsJson = [
        {'id': '1', 'text': 'Milk', 'is_bought': false},
      ];
      final responseBody = jsonEncode({
        'data': itemsJson,
        'meta': {'page': 1, 'total': 1, 'limit': 20, 'offset': 0},
      });

      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await repository.findItems('1');
      expect(result.data.length, 1);
      expect(result.data[0].text, 'Milk');
    });

    group('updateItem', () {
      Future<Map<String, dynamic>> sentBody(Future<void> Function() call) async {
        when(
          () => mockClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode({'id': 'i1', 'text': 'Milk'}), 200));
        await call();
        final body = verify(
          () => mockClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured.single;
        return jsonDecode(body as String) as Map<String, dynamic>;
      }

      test('leaves out fields that were not passed', () async {
        final body = await sentBody(() => repository.updateItem('l1', 'i1', isBought: true));

        expect(body, {'is_bought': true});
      });

      test('clearAmount sends an explicit null', () async {
        final body = await sentBody(() => repository.updateItem('l1', 'i1', text: 'Milk', clearAmount: true));

        expect(body, {'text': 'Milk', 'amount': null});
      });
    });
  });
}
