import '../../l10n/app_localizations.dart';
import 'extensions.dart';

class Validator {
  static String? validateEmail(String value, [AppLocalizations? l10n]) {
    final trimmed = value.trim();
    final regex = RegExp(r'^[\w\-\.\+]+@([\w\-\.]+\.)+[\w\-\.]{2,}$');
    if (!regex.hasMatch(trimmed)) {
      return l10n?.validatorEmail ?? 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String value, [AppLocalizations? l10n]) {
    if (value.length < 8) {
      return l10n?.validatorPasswordLength ?? 'Password must be at least 8 characters.';
    }
    return null;
  }

  static String? validateName(String value, [AppLocalizations? l10n]) {
    if (value.trim().length < 3) {
      return l10n?.validatorNameLength ?? 'Name must be at least 3 characters.';
    }
    return null;
  }

  static String? validateUrl(String value, [AppLocalizations? l10n]) {
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return l10n?.validatorUrl ?? 'Please enter a valid URL.';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return l10n?.validatorUrl ?? 'Please enter a valid URL.';
    }
    return null;
  }

  static String? validateText(String value, [AppLocalizations? l10n]) {
    if (value.trim().isEmpty) {
      return l10n?.validatorText ?? 'Text is too short.';
    }
    return null;
  }

  static String? positiveNumber(String value, [AppLocalizations? l10n]) {
    final parsed = value.asDecimal;
    if (parsed == null || parsed <= 0) {
      return l10n?.validatorPositiveNumber ?? 'Please enter a valid positive number.';
    }
    return null;
  }

  static String? optionalPositiveNumber(String value, [AppLocalizations? l10n]) {
    if (value.trim().isEmpty) return null;
    return positiveNumber(value, l10n);
  }

  static String extractUrl(String text) {
    final regex = RegExp(r'https?://[^\s]+');
    final match = regex.firstMatch(text);
    return match?.group(0) ?? text.trim();
  }
}
