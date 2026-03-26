import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'layouts/error_snackbar_listener.dart';
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
      builder: (context, child) => ErrorSnackBarListener(child: child ?? const SizedBox.shrink()),
    );
  }
}
