import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants.dart';

part 'server_url.g.dart';

@Riverpod(keepAlive: true)
class ServerUrl extends _$ServerUrl {
  static const _storage = FlutterSecureStorage();
  static const String _serverUrlKey = 'server_url';
  static const String defaultUrl = String.fromEnvironment('API_BASE_URL', defaultValue: AppConstants.serverUrl);

  @override
  String build() {
    return defaultUrl;
  }

  Future<void> init() async {
    final storedUrl = await _storage.read(key: _serverUrlKey);
    if (storedUrl != null && storedUrl.isNotEmpty) {
      state = storedUrl;
    }
  }

  Future<void> setUrl(String url) async {
    var trimmed = url.trim();
    if (trimmed.isEmpty) {
      await _storage.delete(key: _serverUrlKey);
      state = build();
    } else {
      if (!trimmed.contains('://')) {
        trimmed = 'https://$trimmed';
      }
      await _storage.write(key: _serverUrlKey, value: trimmed);
      state = trimmed;
    }
  }
}
