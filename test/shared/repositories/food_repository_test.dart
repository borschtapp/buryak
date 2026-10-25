import 'package:buryak/shared/repositories/food_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/repository_harness.dart';

void main() {
  final harness = setUpRepository((ref, client) => FoodRepository(ref: ref, client: client));

  group('FoodRepository.update', () {
    Future<dynamic> patchBody(Future<void> Function() call) =>
        sentBody(harness.client, .patch, call, response: {'id': 'f1', 'slug': 'onion', 'name': 'Onion'});

    test('leaves out fields that were not passed', () async {
      final body = await patchBody(() => harness.repository.update('f1', pantry: true));

      expect(body, {'pantry': true});
    });

    test('sends a new description', () async {
      final body = await patchBody(() => harness.repository.update('f1', description: 'Yellow, for frying'));

      expect(body, {'description': 'Yellow, for frying'});
    });

    test('an empty description sends an explicit null', () async {
      final body = await patchBody(() => harness.repository.update('f1', description: ''));

      expect(body, {'description': null});
    });
  });
}
