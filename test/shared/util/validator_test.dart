import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/util/validator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('Validator.validateEmail', () {
    test('returns null for a valid email', () {
      expect(Validator.validateEmail('user@example.com', l10n), isNull);
    });

    test('returns null for email with plus addressing', () {
      expect(Validator.validateEmail('user+tag@example.com', l10n), isNull);
    });

    test('returns null for email with hyphens and underscores', () {
      expect(Validator.validateEmail('my_user-name@example.com', l10n), isNull);
    });

    test('returns null for email with subdomains', () {
      expect(Validator.validateEmail('user@dept.example.co.uk', l10n), isNull);
    });

    test('returns null for email with long TLD', () {
      expect(Validator.validateEmail('user@history.museum', l10n), isNull);
    });

    test('returns error for email without @', () {
      expect(Validator.validateEmail('notanemail', l10n), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validator.validateEmail('', l10n), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(Validator.validateEmail('   ', l10n), isNotNull);
    });

    test('returns error for email with trailing garbage', () {
      expect(Validator.validateEmail('user@example.com!!!', l10n), isNotNull);
    });

    test('returns error for email with no domain', () {
      expect(Validator.validateEmail('user@', l10n), isNotNull);
    });

    test('returns error for email with invalid TLD', () {
      expect(Validator.validateEmail('user@example.c', l10n), isNotNull); // 1-char tld commonly invalid
    });
  });

  group('Validator.validatePassword', () {
    test('returns null for password with 8+ characters', () {
      expect(Validator.validatePassword('secret12', l10n), isNull);
    });

    test('returns null for long password', () {
      expect(Validator.validatePassword('a' * 64, l10n), isNull);
    });

    test('returns error for password shorter than 8 characters', () {
      expect(Validator.validatePassword('abc', l10n), isNotNull);
    });

    test('returns error for empty password', () {
      expect(Validator.validatePassword('', l10n), isNotNull);
    });

    test('returns null for whitespace-only password of 8+ characters (spaces are valid)', () {
      expect(Validator.validatePassword('        ', l10n), isNull);
    });

    test('returns error for password of exactly 7 characters', () {
      expect(Validator.validatePassword('abcdefg', l10n), isNotNull);
    });
  });

  group('Validator.validateName', () {
    test('returns null for name with 3+ characters', () {
      expect(Validator.validateName('Alice', l10n), isNull);
    });

    test('returns error for name shorter than 3 characters', () {
      expect(Validator.validateName('Al', l10n), isNotNull);
    });

    test('returns error for empty name', () {
      expect(Validator.validateName('', l10n), isNotNull);
    });

    test('returns error for whitespace only (length 3)', () {
      expect(Validator.validateName('   ', l10n), isNotNull);
    });

    test('returns null for name of exactly 3 characters', () {
      expect(Validator.validateName('Ali', l10n), isNull);
    });
  });

  group('Validator.validateUrl', () {
    test('returns null for a valid https URL', () {
      expect(Validator.validateUrl('https://example.com/recipe', l10n), isNull);
    });

    test('returns null for a valid http URL', () {
      expect(Validator.validateUrl('http://example.com', l10n), isNull);
    });

    test('returns null for URL with port', () {
      expect(Validator.validateUrl('http://localhost:8080', l10n), isNull);
    });

    test('returns null for URL with query params', () {
      expect(Validator.validateUrl('https://example.com?q=test&id=1', l10n), isNull);
    });

    test('returns null for URL with fragment', () {
      expect(Validator.validateUrl('https://example.com#section1', l10n), isNull);
    });

    test('returns error for URL without scheme', () {
      expect(Validator.validateUrl('example.com', l10n), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validator.validateUrl('', l10n), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(Validator.validateUrl('   ', l10n), isNotNull);
    });

    test('returns error for ftp scheme', () {
      expect(Validator.validateUrl('ftp://example.com', l10n), isNotNull);
    });
  });

  group('Validator.validateText', () {
    test('returns null for non-empty text', () {
      expect(Validator.validateText('hello', l10n), isNull);
    });

    test('returns error for empty string', () {
      expect(Validator.validateText('', l10n), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(Validator.validateText('   ', l10n), isNotNull);
    });
  });
}
