import 'package:flutter/material.dart';

Widget fadeScaleTransition(Animation<double> animation, Widget child) => FadeTransition(
  opacity: animation,
  child: ScaleTransition(
    scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
    child: child,
  ),
);
