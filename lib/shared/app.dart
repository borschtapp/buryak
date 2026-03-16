import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers/theme.dart';
import 'router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerConfig = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Borscht',
      theme: ThemeProvider.themeLight(),
      darkTheme: ThemeProvider.themeDark(),
      themeMode: ThemeMode.system,
      routerConfig: routerConfig,
    );
  }
}
