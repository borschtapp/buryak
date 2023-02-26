import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'shared/router.dart';
import 'shared/constants.dart';
import 'shared/service/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();

  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Borscht',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: borschtColor,
        // primarySwatch: Colors.green,
      ),
      routerConfig: router,
    );
  }
}
