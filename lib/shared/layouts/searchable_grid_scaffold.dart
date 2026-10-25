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
  });

  final Widget? searchBar;
  final Widget child;
  final Widget? topWidget;

  @override
  Widget build(BuildContext context) {
    // Only the header is capped; the list spans the full width and centres its
    // items itself (see [ContentFrame.gutter]) so its scrollbar sits at the edge.
    return Column(
      children: [
        Material(
          color: context.colors.surface,
          child: ContentFrame(
            maxWidth: UIConstants.defaultMaxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ?topWidget,
                if (searchBar case final bar?)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      UIConstants.paddingMedium,
                      UIConstants.paddingSmall,
                      UIConstants.paddingMedium,
                      4,
                    ),
                    child: bar,
                  ),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
