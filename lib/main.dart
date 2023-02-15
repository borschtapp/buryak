import 'package:flutter/material.dart';

import 'constants.dart';
import 'component/bottom_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Borscht',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: borschtColor,
        // primarySwatch: Colors.green,
      ),
      home: const BottomNavigation(),
    );
  }
}
