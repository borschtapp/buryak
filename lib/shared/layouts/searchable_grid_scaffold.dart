import 'package:flutter/material.dart';

import '../util/extensions.dart';
import '../util/ui_constants.dart';
import 'content_frame.dart';

class SearchableGridScaffold extends StatelessWidget {
  const SearchableGridScaffold({
    super.key,
    this.searchBar,
    required this.child,
    this.topWidget,
    this.maxWidth = 1440,
  });

  final Widget? searchBar;
  final Widget child;
  final Widget? topWidget;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ContentFrame(
      maxWidth: maxWidth,
      child: Column(
        children: [
          Material(
            color: context.colors.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ?topWidget,
                if (searchBar case final bar?)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, UIConstants.paddingSmall, 12, 4),
                    child: bar,
                  ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
