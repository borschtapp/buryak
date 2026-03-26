import 'package:flutter/material.dart';

import '../util/extensions.dart';

class ArticleContent extends StatelessWidget {
  const ArticleContent({
    super.key,
    required this.child,
    this.maxWidth = 960,
  });

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: child,
        ),
      ),
    );
  }
}

class Paragraph extends StatelessWidget {
  final String text;

  const Paragraph(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1, bottom: 2),
      child: Text(text),
    );
  }
}

class Header extends StatelessWidget {
  final String text;

  const Header(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(text, style: context.textTheme.titleMedium),
    );
  }
}
