import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'shared/app.dart';
import 'shared/providers/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserService.init();

  usePathUrlStrategy();
  runApp(const MyApp());
}
