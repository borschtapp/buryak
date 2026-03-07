import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'shared/app.dart';
import 'shared/providers/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'dotenv', isOptional: true);
  await UserService.init();

  usePathUrlStrategy();
  runApp(const MyApp());
}
