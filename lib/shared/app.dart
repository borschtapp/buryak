import 'package:flutter/material.dart';

import 'providers/theme.dart';
import 'router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = ThemeProvider();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Borscht',
      theme: themeProvider.light(),
      darkTheme: themeProvider.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
