import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'layouts/error_snackbar_listener.dart';
import 'providers/locale.dart';
import 'providers/theme.dart';
import 'router.dart';
import 'util/extensions.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerConfig = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: ThemeProvider.themeLight(),
      darkTheme: ThemeProvider.themeDark(),
      themeMode: ThemeMode.system,
      routerConfig: routerConfig,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => ErrorSnackBarListener(child: child ?? const SizedBox.shrink()),
    );
  }
}
