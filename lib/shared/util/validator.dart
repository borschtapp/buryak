class Validator {
  static String? validateEmail(String value) {
    final trimmed = value.trim();
    final regex = RegExp(r'^[\w\-\.\+]+@([\w\-\.]+\.)+[\w\-\.]{2,}$');
    if (!regex.hasMatch(trimmed)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  static String? validateName(String value) {
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters.';
    }
    return null;
  }

  static String? validateUrl(String value) {
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Please enter a valid URL.';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'Please enter a valid URL.';
    }
    return null;
  }

  static String? validateText(String value) {
    if (value.trim().isEmpty) {
      return 'Text is too short.';
    }
    return null;
  }

  static String extractUrl(String text) {
    final regex = RegExp(r'https?://[^\s]+');
    final match = regex.firstMatch(text);
    return match?.group(0) ?? text.trim();
  }
}
