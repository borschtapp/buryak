import 'package:flutter_test/flutter_test.dart';
import 'package:buryak/shared/validator.dart';

void main() {
  group('Validator.validateEmail', () {
    test('returns null for a valid email', () {
      expect(Validator.validateEmail('user@example.com'), isNull);
    });

    test('returns null for email with plus addressing', () {
      expect(Validator.validateEmail('user+tag@example.com'), isNull);
    });

    test('returns null for email with hyphens and underscores', () {
      expect(Validator.validateEmail('my_user-name@example.com'), isNull);
    });

    test('returns null for email with subdomains', () {
      expect(Validator.validateEmail('user@dept.example.co.uk'), isNull);
    });

    test('returns null for email with long TLD', () {
      expect(Validator.validateEmail('user@history.museum'), isNull);
    });

    test('returns error for email without @', () {
      expect(Validator.validateEmail('notanemail'), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validator.validateEmail(''), isNotNull);
    });

    test('returns error for email with trailing garbage', () {
      expect(Validator.validateEmail('user@example.com!!!'), isNotNull);
    });

    test('returns error for email with no domain', () {
      expect(Validator.validateEmail('user@'), isNotNull);
    });

    test('returns error for email with invalid TLD', () {
      expect(Validator.validateEmail('user@example.c'), isNotNull); // 1-char tld commonly invalid
    });
  });

  group('Validator.validatePassword', () {
    test('returns null for password with 6+ characters', () {
      expect(Validator.validatePassword('secret'), isNull);
    });

    test('returns null for long password', () {
      expect(Validator.validatePassword('a' * 64), isNull);
    });

    test('returns error for password shorter than 6 characters', () {
      expect(Validator.validatePassword('abc'), isNotNull);
    });

    test('returns error for empty password', () {
      expect(Validator.validatePassword(''), isNotNull);
    });

    test('returns error for password of exactly 5 characters', () {
      expect(Validator.validatePassword('abcde'), isNotNull);
    });
  });

  group('Validator.validateName', () {
    test('returns null for name with 3+ characters', () {
      expect(Validator.validateName('Alice'), isNull);
    });

    test('returns error for name shorter than 3 characters', () {
      expect(Validator.validateName('Al'), isNotNull);
    });

    test('returns error for empty name', () {
      expect(Validator.validateName(''), isNotNull);
    });

    test('returns null for name of exactly 3 characters', () {
      expect(Validator.validateName('Ali'), isNull);
    });
  });

  group('Validator.validateUrl', () {
    test('returns null for a valid https URL', () {
      expect(Validator.validateUrl('https://example.com/recipe'), isNull);
    });

    test('returns null for a valid http URL', () {
      expect(Validator.validateUrl('http://example.com'), isNull);
    });

    test('returns null for URL with port', () {
      expect(Validator.validateUrl('http://localhost:8080'), isNull);
    });

    test('returns null for URL with query params', () {
      expect(Validator.validateUrl('https://example.com?q=test&id=1'), isNull);
    });

    test('returns null for URL with fragment', () {
      expect(Validator.validateUrl('https://example.com#section1'), isNull);
    });

    test('returns error for URL without scheme', () {
      expect(Validator.validateUrl('example.com'), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validator.validateUrl(''), isNotNull);
    });

    test('returns error for ftp scheme', () {
      expect(Validator.validateUrl('ftp://example.com'), isNotNull);
    });
  });

  group('Validator.validateText', () {
    test('returns null for non-empty text', () {
      expect(Validator.validateText('hello'), isNull);
    });

    test('returns error for empty string', () {
      expect(Validator.validateText(''), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(Validator.validateText('   '), isNotNull);
    });
  });
}
