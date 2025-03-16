import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'shared/app.dart';
import 'shared/providers/storage.dart';

void main() async {
  await dotenv.load(fileName: "dotenv", isOptional: true);

  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();

  usePathUrlStrategy();
  runApp(const MyApp());
}
