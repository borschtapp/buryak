import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale.g.dart';

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  static const _storage = FlutterSecureStorage();
  static const _key = 'app_locale';

  @override
  Locale? build() => null; // null = follow system locale

  /// Called once at startup from main() to restore the saved locale.
  Future<void> init() async {
    final saved = await _storage.read(key: _key);
    if (saved != null && saved.isNotEmpty) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    await _storage.write(key: _key, value: locale.languageCode);
    state = locale;
  }

  Future<void> clearLocale() async {
    await _storage.delete(key: _key);
    state = null;
  }
}
