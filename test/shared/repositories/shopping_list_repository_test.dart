import 'dart:convert';

import 'package:buryak/shared/repositories/shopping_list_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../helpers/repository_harness.dart';

void main() {
  final harness = setUpRepository((ref, client) => ShoppingListRepository(ref: ref, client: client));

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
        () => harness.client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await harness.repository.findAll();
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
        () => harness.client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await harness.repository.findItems('1');
      expect(result.data.length, 1);
      expect(result.data[0].text, 'Milk');
    });

    test('createItems sends one entry per item, leaving out unset fields', () async {
      final body = await sentBody(
        harness.client,
        .post,
        () => harness.repository.createItems('l1', [
          (text: 'red onions', amount: 2, unitId: 'pc', foodId: 'onion'),
          (text: 'water', amount: null, unitId: null, foodId: null),
        ]),
        response: [],
      );

      expect(body, [
        {'text': 'red onions', 'amount': 2, 'unit_id': 'pc', 'food_id': 'onion'},
        {'text': 'water'},
      ]);
    });

    group('updateItem', () {
      Future<dynamic> patchBody(Future<void> Function() call) =>
          sentBody(harness.client, .patch, call, response: {'id': 'i1', 'text': 'Milk'});

      test('leaves out fields that were not passed', () async {
        final body = await patchBody(() => harness.repository.updateItem('l1', 'i1', isBought: true));

        expect(body, {'is_bought': true});
      });

      test('clearAmount sends an explicit null', () async {
        final body = await patchBody(() => harness.repository.updateItem('l1', 'i1', text: 'Milk', clearAmount: true));

        expect(body, {'text': 'Milk', 'amount': null});
      });
    });
  });
}
