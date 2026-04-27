import 'package:flutter/material.dart';

class TwoPaneLayout extends StatelessWidget {
  const TwoPaneLayout({
    super.key,
    required this.leftPane,
    required this.rightPane,
    this.leftFlex = 3,
    this.rightFlex = 2,
  });

  final Widget leftPane;
  final Widget rightPane;
  final int leftFlex;
  final int rightFlex;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: leftFlex,
          child: leftPane,
        ),
        Expanded(
          flex: rightFlex,
          child: rightPane,
        ),
      ],
    );
  }
}
