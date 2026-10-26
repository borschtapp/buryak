import 'package:flutter/material.dart';

import '../util/extensions.dart';
import '../util/ui_constants.dart';
import 'content_frame.dart';

class SearchableGridScaffold extends StatelessWidget {
  const SearchableGridScaffold({
    super.key,
    required this.searchBar,
    required this.child,
  });

  final Widget searchBar;
  final Widget child;

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
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingMedium,
              vertical: UIConstants.paddingSmall,
            ),
            child: searchBar,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
