class Validator {
  static String? validateEmail(String value) {
    final regex = RegExp(r'^[\w\-\.\+]+@([\w\-\.]+\.)+[\w\-\.]{2,}$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String value) {
    final regex = RegExp(r'^.{6,}$');
    if (!regex.hasMatch(value)) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? validateName(String value) {
    if (value.length < 3) {
      return 'Username is too short.';
    }
    return null;
  }

  static String? validateUrl(String value) {
    final regex = RegExp(r'^https?:\/\/[^\s$.?#][^\s]*$');
    if (!regex.hasMatch(value)) {
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
}
