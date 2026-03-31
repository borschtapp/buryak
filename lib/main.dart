import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'shared/app.dart';
import 'shared/providers/server_url.dart';
import 'shared/providers/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  // Initialize auth before the widget tree mounts so GoRouter sees the correct
  // auth state from the very first URL match. Without this, the intermediate
  // MaterialApp(home:) causes Flutter's Navigator to fail on deep-link URLs
  // (e.g. /recipes, /recipes/:id) before GoRouter takes over.
  final container = ProviderContainer();
  try {
    await container.read(serverUrlProvider.notifier).init();
    await container.read(authProvider.notifier).init();
  } catch (e) {
    debugPrint('Auth initialization failed: $e');
    // We could potentially navigate to an error screen here, but for now
    // the AuthNotifier.init() already clears storage and logs out on error.
  }

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}
