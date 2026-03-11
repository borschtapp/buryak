import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'shared/app.dart';
import 'shared/providers/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserService.init();

  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();
  runApp(const MyApp());
}
