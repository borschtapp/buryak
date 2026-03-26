import 'dart:convert';

import 'package:buryak/shared/repositories/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_user.dart';

final dummyProvider = Provider<Ref>((ref) => ref);
late Ref mockRef;

// Minimal concrete Repository subclass for testing
class _TestRepo extends Repository {
  _TestRepo() : super(ref: mockRef, module: '/api', baseUrlOverride: 'http://localhost');
}

void main() {
  setUpAll(() {
    final container = ProviderContainer();
    mockRef = container.read(dummyProvider);
  });

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({
      'user': jsonEncode(fakeUserJson()),
    });
  });

  group('GeneralApiException', () {
    test('toString returns the message', () {
      final e = GeneralApiException(message: 'something went wrong');
      expect(e.toString(), equals('something went wrong'));
    });

    test('is an Exception', () {
      final e = GeneralApiException(message: 'test');
      expect(e, isA<Exception>());
    });
  });

  group('FieldsApiException', () {
    test('toString returns first field name and first error', () {
      final e = FieldsApiException(
        message: 'Validation failed',
        fields: {
          'email': ['Email is taken'],
          'name': ['Name is too short'],
        },
      );
      expect(e.toString(), equals('email: Email is taken'));
    });

    test('is a GeneralApiException', () {
      final e = FieldsApiException(
        message: 'Validation failed',
        fields: {
          'email': ['taken'],
        },
      );
      expect(e, isA<GeneralApiException>());
    });
  });

  group('handleFormErrors', () {
    test('returns FieldsApiException when fields key is present', () {
      final json = {
        'message': 'Validation failed',
        'fields': {
          'email': ['taken'],
        },
      };
      final result = handleFormErrors(json);
      expect(result, isA<FieldsApiException>());
    });

    test('returns GeneralApiException when no fields key', () {
      final json = {'message': 'Server error'};
      final result = handleFormErrors(json);
      expect(result, isA<GeneralApiException>());
      expect(result, isNot(isA<FieldsApiException>()));
    });

    test('uses fallback message when message key is missing', () {
      final json = <String, dynamic>{};
      final e = handleFormErrors(json) as GeneralApiException;
      expect(e.message, equals('An error occurred'));
    });

    test('carries the message from the JSON', () {
      final json = {'message': 'Custom error message'};
      final e = handleFormErrors(json) as GeneralApiException;
      expect(e.message, equals('Custom error message'));
    });
  });

  group('Repository.getUrlString', () {
    test('builds correct URL without query string', () {
      final repo = _TestRepo();
      expect(repo.getUrlString(path: '/test'), equals('http://localhost/api/test'));
    });

    test('appends query parameters when provided', () {
      final repo = _TestRepo();
      expect(
        repo.getUrlString(path: '/test', queryParams: {'q': 'borscht'}),
        equals('http://localhost/api/test?q=borscht'),
      );
    });

    test('filters out null values', () {
      final repo = _TestRepo();
      expect(
        repo.getUrlString(path: '/test', queryParams: {'q': null}),
        equals('http://localhost/api/test'),
      );
    });

    test('filters out "null" strings', () {
      final repo = _TestRepo();
      expect(
        repo.getUrlString(path: '/test', queryParams: {'q': 'null'}),
        equals('http://localhost/api/test'),
      );
    });

    test('filters out mixed invalid values', () {
      final repo = _TestRepo();
      expect(
        repo.getUrlString(
          path: '/test',
          queryParams: {
            'q': 'borscht',
            'filter': null,
            'sort': 'null',
          },
        ),
        equals('http://localhost/api/test?q=borscht'),
      );
    });
  });
}
